# frozen_string_literal: true

module Formeze
  autoload :Errors, 'formeze/errors'
  autoload :Field, 'formeze/field'
  autoload :Form, 'formeze/form'
  autoload :FormData, 'formeze/form_data'
  autoload :Presence, 'formeze/presence'
  autoload :Validation, 'formeze/validation'

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
      form_data = FormData.parse(input)

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

    def add_error(field, message, default = nil)
      message = Formeze::Errors.translate(message, default) unless default.nil?

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

  LABELS_SCOPE = [:formeze, :labels].freeze

  def self.translate(key, **options)
    defined?(I18n) ? I18n.translate(key, **options) : options.fetch(:default)
  end

  def self.setup(form)
    form.send :include, InstanceMethods

    form.extend ClassMethods
  end
end
