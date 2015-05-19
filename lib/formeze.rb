require 'cgi'

module Formeze
  class Field
    attr_reader :name

    def initialize(name, options = {})
      @name, @options = name, options
    end

    def validate(value, form)
      value = Formeze.scrub(value, @options[:scrub])

      if value !~ /\S/
        form.add_error(self, error(:required, 'is required')) if required?

        value = blank_value if blank_value?
      else
        form.add_error(self, error(:not_multiline, 'cannot contain newlines')) if !multiline? && value.lines.count > 1

        form.add_error(self, error(:too_long, 'is too long')) if too_long?(value)

        form.add_error(self, error(:too_short, 'is too short')) if too_short?(value)

        form.add_error(self, error(:no_match, 'is invalid')) if no_match?(value)

        form.add_error(self, error(:bad_value, 'is invalid')) if values? && !values.include?(value)
      end

      value = Array(form.send(name)).push(value) if multiple?

      form.send(:"#{name}=", value)
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
      @options.fetch(:label) { Formeze.translate(name, :scope => [:formeze, :labels], :default => Formeze.label(name)) }
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
      value.chars.count > @options.fetch(:maxlength) { 64 }
    end

    def too_short?(value)
      @options.has_key?(:minlength) && value.chars.count < @options.fetch(:minlength)
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

    def field_value?(form)
      form.send(@field.name) =~ /\S/
    end

    def field_errors?(form)
      form.errors_on?(@field.name)
    end

    def validate(form)
      if validates?(form) && field_value?(form) && !field_errors?(form)
        return_value = if @block.arity == 1
          @block.call(form.send(@field.name))
        else
          form.instance_eval(&@block)
        end

        form.add_error(@field, error_message) unless return_value
      end
    end
  end

  module ClassMethods
    def fields
      @fields ||= {}
    end

    def field(*args)
      field = Field.new(*args)

      fields[field.name] = field

      attr_accessor field.name
    end

    def validations
      @validations ||= []
    end

    def validates(field_name, options = {}, &block)
      validations << Validation.new(fields[field_name], options, &block)
    end
  end

  class KeyError < StandardError; end

  class ValueError < StandardError; end

  class ValidationError < StandardError; end

  module InstanceMethods
    def fill(object)
      self.class.fields.each_value do |field|
        if Hash === object && object.has_key?(field.name)
          send(:"#{field.name}=", object[field.name])
        elsif object.respond_to?(field.name)
          send(:"#{field.name}=", object.send(field.name))
        end
      end

      return self
    end

    def parse(encoded_form_data)
      form_data = CGI.parse(encoded_form_data)

      self.class.fields.each_value do |field|
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

      return self
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
      self.class.fields.values.inject({}) do |hash, field|
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

  def self.label(field_name)
    field_name.to_s.tr('_', ' ').capitalize
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
