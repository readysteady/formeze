# frozen_string_literal: true

class Formeze::Field
  include Formeze::Presence

  attr_reader :name

  def initialize(name, **options)
    @name, @options = name, options
  end

  def validate_all(values, form)
    size = 0

    values.each do |value|
      if String === value
        value = validate(value, form)
      else
        form.add_error(self, :not_accepted) unless acceptable_file?(value)

        size += value.size
      end

      value = Array(form.send(name)).push(value) if multiple?

      form.send(:"#{name}=", value)
    end

    form.add_error(self, :too_large) if maxsize? && size > maxsize
  end

  def validate(value, form)
    value = Formeze.scrub(value, @options[:scrub])

    if blank?(value)
      form.add_error(self, :required) if required?

      value = blank_value
    else
      form.add_error(self, :not_multiline) if !multiline? && value.lines.count > 1

      form.add_error(self, :too_long) if too_long?(value)

      form.add_error(self, :too_short) if too_short?(value)

      form.add_error(self, :no_match) if no_match?(value)

      form.add_error(self, :bad_value) if values? && !values.include?(value)
    end

    value
  end

  def acceptable_file?(object)
    types = MIME::Types.type_for(object.original_filename)

    if object.content_type == 'application/octet-stream'
      types.any? { |type| accept.include?(type) }
    else
      type = MIME::Types[object.content_type].first

      accept.include?(type) && types.include?(type)
    end
  end

  def key
    @key ||= @name.to_s
  end

  def key_required?
    @options.fetch(:key_required) { true }
  end

  def label
    @options.fetch(:label) { Formeze::Labels.translate(name) }
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

  def accept?
    @options.key?(:accept)
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

  def blank_value
    @options[:blank]
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

  def undefined?(form)
    if defined_if?
      !Formeze::Block.evaluate(form, defined_if)
    elsif defined_unless?
      Formeze::Block.evaluate(form, defined_unless)
    else
      false
    end
  end

  def fill_proc?
    @options.key?(:fill)
  end

  def fill_proc
    @options[:fill]
  end
end
