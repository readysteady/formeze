# frozen_string_literal: true

module Formeze::Errors
  SCOPE = [:formeze, :errors].freeze

  DEFAULT = {
    bad_value: 'is invalid',
    not_accepted: 'is not an accepted file type',
    not_multiline: 'cannot contain newlines',
    no_match: 'is invalid',
    required: 'is required',
    too_large: 'is too large',
    too_long: 'is too long',
    too_short: 'is too short',
  }

  def self.translate(error, scope:)
    default = DEFAULT[error] || 'is invalid'

    return default unless defined?(I18n)

    message = I18n.translate(error, scope: scope, default: nil)

    message || I18n.translate(error, scope: SCOPE, default: default)
  end
end
