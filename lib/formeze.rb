# frozen_string_literal: true
require 'cgi'

module Formeze
  module Presence
    REGEXP = /\S/

    def present?(string)
      string =~ REGEXP
    end

    def blank?(string)
      string !~ REGEXP
    end
  end

  private_constant :Presence

  class Field
    include Presence

    attr_reader :name

    def initialize(name, **options)
      @name, @options = name, options
    end

    def validate_all(values, form)
      size = 0

      values.each do |value|
        if String === value
          validate(value, form)
        else
          validate_file(value, form)

          size += value.size
        end
      end

      form.add_error(self, error(:too_large, 'is too large')) if maxsize? && size > maxsize
    end

    def validate(value, form)
      value = Formeze.scrub(value, @options[:scrub])

      if blank?(value)
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

    def validate_file(object, form)
      type = MIME::Types[object.content_type].first

      filename_type = MIME::Types.type_for(object.original_filename).first

      if type.nil? || type != filename_type || !accept.include?(type)
        form.add_error(self, error(:not_accepted, 'is not an accepted file type'))
      end

      object = Array(form.send(name)).push(object) if multiple?

      form.send(:"#{name}=", object)
    end

    def error(key, default)
      Formeze.translate(key, scope: ERRORS_SCOPE, default: default)
    end

    def key
      @key ||= @name.to_s
    end

    def key_required?
      @options.fetch(:key_required) { true }
    end

    def label
      @options.fetch(:label) { Formeze.translate(name, scope: LABELS_SCOPE, default: Formeze.label(name)) }
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

    def maxsize?
      @options.key?(:maxsize)
    end

    def maxsize
      @options.fetch(:maxsize)
    end

    def accept
      @accept ||= @options.fetch(:accept).split(',').flat_map { |type| MIME::Types[type] }
    end

    def too_long?(value)
      value.chars.count > @options.fetch(:maxlength) { 64 }
    end

    def too_short?(value)
      @options.key?(:minlength) && value.chars.count < @options.fetch(:minlength)
    end

    def no_match?(value)
      @options.key?(:pattern) && value !~ @options[:pattern]
    end

    def blank_value?
      @options.key?(:blank)
    end

    def blank_value
      @options.fetch(:blank)
    end

    def values?
      @options.key?(:values)
    end

    def values
      @options.fetch(:values)
    end

    def defined_if?
      @options.key?(:defined_if)
    end

    def defined_if
      @options.fetch(:defined_if)
    end

    def defined_unless?
      @options.key?(:defined_unless)
    end

    def defined_unless
      @options.fetch(:defined_unless)
    end
  end

  class Validation
    include Presence

    def initialize(field, **kwargs, &block)
      @field = field

      @error = kwargs[:error] || :invalid

      @precondition = kwargs[:if]

      @block = block
    end

    def error_message
      Formeze.translate(@error, scope: ERRORS_SCOPE, default: 'is invalid')
    end

    def validates?(form)
      @precondition ? form.instance_eval(&@precondition) : true
    end

    def field_value?(form)
      present?(form.send(@field.name))
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

    def field(name, **options)
      field = Field.new(name, **options)

      fields[field.name] = field

      attr_accessor field.name
    end

    def validations
      @validations ||= []
    end

    def validates(field_name, **options, &block)
      validations << Validation.new(fields[field_name], **options, &block)
    end
  end

  class KeyError < StandardError; end

  class ValueError < StandardError; end

  class ValidationError < StandardError; end

  class RequestCGI < CGI
    def env_table
      @options[:request].env
    end

    def stdinput
      @options[:request].body
    end
  end

  private_constant :RequestCGI

  RAILS_FORM_KEYS = %w[utf8 authenticity_token commit]

  private_constant :RAILS_FORM_KEYS

  module InstanceMethods
    def fill(object)
      self.class.fields.each_value do |field|
        if Hash === object && object.key?(field.name)
          send(:"#{field.name}=", object[field.name])
        elsif object.respond_to?(field.name)
          send(:"#{field.name}=", object.send(field.name))
        end
      end

      return self
    end

    def parse(input)
      form_data = if String === input
        CGI.parse(input)
      else
        RequestCGI.new(request: input).params
      end

      self.class.fields.each_value do |field|
        next unless field_defined?(field)

        unless form_data.key?(field.key)
          next if field.multiple? || !field.key_required?

          raise KeyError, "missing form key: #{field.key}"
        end

        values = form_data.delete(field.key)

        if values.length > 1
          raise ValueError unless field.multiple?
        end

        field.validate_all(values, self)
      end

      if defined?(Rails)
        RAILS_FORM_KEYS.each do |key|
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
      self.class.fields.values.each_with_object({}) do |field, hash|
        hash[field.name] = send(field.name)
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

  ERRORS_SCOPE = [:formeze, :errors].freeze

  private_constant :ERRORS_SCOPE

  LABELS_SCOPE = [:formeze, :labels].freeze

  private_constant :LABELS_SCOPE

  def self.translate(key, **options)
    defined?(I18n) ? I18n.translate(key, **options) : options.fetch(:default)
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
