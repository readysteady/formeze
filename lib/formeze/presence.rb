module Formeze::Presence
  REGEXP = /\S/

  def present?(string)
    string =~ REGEXP
  end

  def blank?(string)
    string !~ REGEXP
  end
end
