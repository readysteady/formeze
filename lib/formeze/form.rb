class Formeze::Form
  def self.inherited(subclass)
    Formeze.setup(subclass)
  end
end
