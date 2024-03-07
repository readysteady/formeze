module Formeze::Labels
  SCOPE = [:formeze, :labels].freeze

  def self.translate(name)
    default = Formeze.label(name)

    if defined?(I18n)
      return I18n.translate(name, scope: SCOPE, default: default)
    end

    default
  end
end
