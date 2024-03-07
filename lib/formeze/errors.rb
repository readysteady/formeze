module Formeze::Errors
  SCOPE = [:formeze, :errors].freeze

  def self.translate(error, default)
    if defined?(I18n)
      return I18n.translate(error, scope: SCOPE, default: default)
    end

    default
  end
end
