module Formeze::Presence
  REGEXP = /\S/

  def present?(value)
    return false if value.nil?
    return false if value.respond_to?(:empty?) && value.empty?
    return false if value.is_a?(String) && value !~ REGEXP
    return true
  end

  def blank?(value)
    !present?(value)
  end
end
