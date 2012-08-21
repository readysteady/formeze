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
    end

    def validate(value, &block)
      if value !~ /\S/ # blank
        block.call(error(:required, 'is required')) if required?
      else
        block.call(error(:not_multiline, 'cannot contain newlines')) if !multiline? && value.lines.count > 1

        block.call(error(:too_long, 'is too long')) if value.chars.count > char_limit

        block.call(error(:too_long, 'is too long')) if word_limit? && value.scan(/\w+/).length > word_limit

        block.call(error(:no_match, 'is invalid')) if pattern? && value !~ pattern

        block.call(error(:bad_value, 'is invalid')) if values? && !values.include?(value)
      end
    end

    def error(i18n_key, default)
      translate(i18n_key, scope: [:formeze, :errors], default: default)
    end

    def key
      @key ||= @name.to_s
    end

    def key_required?
      @options.fetch(:key_required) { true }
    end

    def label
      if @options.has_key?(:label)
        @options[:label]
      else
        translate(name, scope: [:formeze, :labels], default: Label.new(name))
      end
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

    def char_limit
      @options.fetch(:char_limit) { 64 }
    end

    def word_limit?
      @options.has_key?(:word_limit)
    end

    def word_limit
      @options.fetch(:word_limit)
    end

    def pattern?
      @options.has_key?(:pattern)
    end

    def pattern
      @options.fetch(:pattern)
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

    def translate(key, options)
      if defined?(I18n)
        I18n.translate(key, options)
      else
        options.fetch(:default)
      end
    end
  end

  module ArrayAttrAccessor
    def array_attr_reader(name)
      define_method(name) do
        ivar = :"@#{name}"

        values = instance_variable_get(ivar)

        if values.nil?
          values = []

          instance_variable_set(ivar, values)
        end

        values
      end
    end

    def array_attr_writer(name)
      define_method(:"#{name}=") do |value|
        ivar = :"@#{name}"

        values = instance_variable_get(ivar)

        if values.nil?
          instance_variable_set(ivar, [value])
        else
          values << value
        end
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
      @fields ||= []
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

    def checks
      @checks ||= []
    end

    def check(&block)
      checks << block
    end

    def errors
      @errors ||= []
    end

    def error(message)
      errors << message
    end
  end

  class KeyError < StandardError; end

  class ValueError < StandardError; end

  class UserError < StandardError; end

  module InstanceMethods
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
          field.validate(value) do |error|
            errors << UserError.new("#{field.label} #{error}")
          end

          send(:"#{field.name}=", value)
        end
      end

      raise KeyError unless form_data.empty?

      self.class.checks.zip(self.class.errors) do |check, error|
        instance_eval(&check) ? next : errors << UserError.new(error)
      end
    end

    def field_defined?(field)
      if field.defined_if?
        instance_eval(&field.defined_if)
      elsif field.defined_unless?
        !instance_eval(&field.defined_unless)
      else
        true
      end
    end

    def errors
      @errors ||= []
    end

    def valid?
      errors.empty?
    end
  end

  def self.setup(form)
    form.send :include, InstanceMethods

    form.extend ClassMethods

    if on_rails?
      form.field(:utf8, key_required: false)

      form.field(:authenticity_token, key_required: false)
    end
  end

  def self.on_rails?
    defined?(Rails)
  end
end
