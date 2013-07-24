require 'cgi'

module Formeze
  class Label
    def initialize(name)
      @name = name
    end

    def to_s
      @name.to_s.tr('_', ' ').capitalize
    end
  end

  class Field
    attr_reader :name

    def initialize(name, options = {})
      @name, @options = name, options

      if options.has_key?(:word_limit)
        Kernel.warn '[formeze] :word_limit option is deprecated, please use custom validation instead'
      end
    end

    def validate(value, form)
      value = Formeze.scrub(value, @options[:scrub])

      if value !~ /\S/
        form.add_error(self, error(:required, 'is required')) if required?

        form.send(:"#{name}=", blank_value? ? blank_value : value)
      else
        form.add_error(self, error(:not_multiline, 'cannot contain newlines')) if !multiline? && value.lines.count > 1

        form.add_error(self, error(:too_long, 'is too long')) if too_long?(value)

        form.add_error(self, error(:too_short, 'is too short')) if too_short?(value)

        form.add_error(self, error(:no_match, 'is invalid')) if no_match?(value)

        form.add_error(self, error(:bad_value, 'is invalid')) if values? && !values.include?(value)

        form.send(:"#{name}=", value)
      end
    end

    def error(key, default)
      Formeze.translate(key, :scope => [:formeze, :errors], :default => default)
    end

    def key
      @key ||= @name.to_s
    end

    def key_required?
      @options.fetch(:key_required) { true }
    end

    def label
      @options.fetch(:label) { Formeze.translate(name, :scope => [:formeze, :labels], :default => Label.new(name)) }
    end

    def type
      return if multiline? or multiple?
      @options.fetch(:type) { "text" }
    end

    def placeholder
      return if multiline? or multiple?
      @options.fetch(:placeholder) { "" }
    end

    def rows
      @options.fetch(:rows) { 10 }
    end

    def cols
      @options.fetch(:cols) { 50 }
    end

    def required?
      @options.fetch(:required) { true }
    end

    def multiline?
      @options.fetch(:multiline) { false }
    end

    def multiple?
      @options.fetch(:multiple) { false }
    end

    def too_long?(value)
      too_many_characters?(value) || too_many_words?(value)
    end

    def too_short?(value)
      @options.has_key?(:minlength) && value.chars.count < @options.fetch(:minlength)
    end

    def too_many_characters?(value)
      value.chars.count > @options.fetch(:maxlength) { 64 }
    end

    def too_many_words?(value)
      @options.has_key?(:word_limit) && value.scan(/\w+/).length > @options[:word_limit]
    end

    def no_match?(value)
      @options.has_key?(:pattern) && value !~ @options[:pattern]
    end

    def blank_value?
      @options.has_key?(:blank)
    end

    def blank_value
      @options.fetch(:blank)
    end

    def values?
      @options.has_key?(:values)
    end

    def values
      @options.fetch(:values)
    end

    def defined_if?
      @options.has_key?(:defined_if)
    end

    def defined_if
      @options.fetch(:defined_if)
    end

    def defined_unless?
      @options.has_key?(:defined_unless)
    end

    def defined_unless
      @options.fetch(:defined_unless)
    end
  end

  class FieldSet
    include Enumerable

    def initialize
      @fields, @index = [], {}
    end

    def each(&block)
      @fields.each(&block)
    end

    def <<(field)
      @fields << field

      @index[field.name] = field
    end

    def [](field_name)
      @index.fetch(field_name)
    end
  end

  class Validation
    def initialize(field, options, &block)
      @field, @options, @block = field, options, block
    end

    def error_key
      @options.fetch(:error) { :invalid }
    end

    def error_message
      Formeze.translate(error_key, :scope => [:formeze, :errors], :default => 'is invalid')
    end

    def validates?(form)
      @options.has_key?(:when) ? form.instance_eval(&@options[:when]) : true
    end

    def value?(form)
      form.send(@field.name) =~ /\S/
    end

    def validate(form)
      if validates?(form) && value?(form)
        return_value = if @block.arity == 1
          @block.call(form.send(@field.name))
        else
          form.instance_eval(&@block)
        end

        form.add_error(@field, error_message) unless return_value
      end
    end
  end

  module ArrayAttrAccessor
    def array_attr_reader(name)
      define_method(name) do
        ivar = :"@#{name}"

        instance_variable_defined?(ivar) ? Array(instance_variable_get(ivar)) : []
      end
    end

    def array_attr_writer(name)
      define_method(:"#{name}=") do |value|
        ivar = :"@#{name}"

        instance_variable_set(ivar, send(name) + [value])
      end
    end

    def array_attr_accessor(name)
      array_attr_reader(name)
      array_attr_writer(name)
    end
  end

  module ClassMethods
    include ArrayAttrAccessor

    def fields
      @fields ||= FieldSet.new
    end

    def field(*args)
      field = Field.new(*args)

      fields << field

      if field.multiple?
        array_attr_accessor field.name
      else
        attr_accessor field.name
      end
    end

    def validations
      @validations ||= []
    end

    def validates(field_name, options = {}, &block)
      validations << Validation.new(fields[field_name], options, &block)
    end

    def parse(encoded_form_data)
      new.tap { |form| form.parse(encoded_form_data) }
    end
  end

  class KeyError < StandardError; end

  class ValueError < StandardError; end

  class ValidationError < StandardError; end

  module InstanceMethods
    def fill(object)
      self.class.fields.each do |field|
        if Hash === object && object.has_key?(field.name)
          send(:"#{field.name}=", object[field.name])
        elsif object.respond_to?(field.name)
          send(:"#{field.name}=", object.send(field.name))
        end
      end
    end

    def parse(encoded_form_data)
      form_data = CGI.parse(encoded_form_data)

      self.class.fields.each do |field|
        next unless field_defined?(field)

        unless form_data.has_key?(field.key)
          next if field.multiple? || !field.key_required?

          raise KeyError, "missing form key: #{field.key}"
        end

        values = form_data.delete(field.key)

        if values.length > 1
          raise ValueError unless field.multiple?
        end

        values.each do |value|
          field.validate(value, self)
        end
      end

      if defined?(Rails)
        %w(utf8 authenticity_token).each do |key|
          form_data.delete(key)
        end
      end

      unless form_data.empty?
        raise KeyError, "unexpected form keys: #{form_data.keys.sort.join(', ')}"
      end

      self.class.validations.each do |validation|
        validation.validate(self)
      end
    end

    def add_error(field, message)
      error = ValidationError.new("#{field.label} #{message}")

      errors << error

      field_errors[field.name] << error
    end

    def valid?
      errors.empty?
    end

    def errors?
      errors.size > 0
    end

    def errors
      @errors ||= []
    end

    def errors_on?(field_name)
      field_errors[field_name].size > 0
    end

    def errors_on(field_name)
      field_errors[field_name]
    end

    def to_h
      self.class.fields.inject({}) do |hash, field|
        hash[field.name] = send(field.name)
        hash
      end
    end

    alias_method :to_hash, :to_h

    private

    def field_defined?(field)
      if field.defined_if?
        instance_eval(&field.defined_if)
      elsif field.defined_unless?
        !instance_eval(&field.defined_unless)
      else
        true
      end
    end

    def field_errors
      @field_errors ||= Hash.new { |h, k| h[k] = [] }
    end
  end

  def self.scrub_methods
    @scrub_methods ||= {
      :strip => :strip.to_proc,
      :upcase => :upcase.to_proc,
      :downcase => :downcase.to_proc,
      :squeeze => proc { |string| string.squeeze(' ') },
      :squeeze_lines => proc { |string| string.gsub(/(\r?\n)(\r?\n)(\r?\n)+/, '\\1\\2') }
    }
  end

  def self.scrub(input, method_names)
    Array(method_names).inject(input) do |tmp, method_name|
      scrub_methods.fetch(method_name).call(tmp)
    end
  end

  def self.translate(key, options)
    defined?(I18n) ? I18n.translate(key, options) : options.fetch(:default)
  end

  def self.setup(form)
    form.send :include, InstanceMethods

    form.extend ClassMethods
  end

  class Form
    def self.inherited(subclass)
      Formeze.setup(subclass)
    end
  end
end
