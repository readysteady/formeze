# frozen_string_literal: true

class Formeze::Validation
  include Formeze::Presence

  def initialize(field, **kwargs, &block)
    @field = field

    @error = kwargs[:error] || :invalid

    @precondition = kwargs[:if]

    @block = block
  end

  def validates?(form)
    @precondition ? Formeze::Block.evaluate(form, @precondition) : true
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

      form.add_error(@field, @error, 'is invalid') unless return_value
    end
  end
end
