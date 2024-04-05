module Formeze::Condition
  def self.evaluate(instance, block)
    block = block.to_proc

    if block.arity.zero?
      instance.instance_exec(&block)
    else
      instance.instance_eval(&block)
    end
  end
end
