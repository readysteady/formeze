require 'cgi'

module Formeze::FormData
  class CGI < ::CGI
    def env_table
      @options[:request].env
    end

    def stdinput
      @options[:request].body.tap do |body|
        body.rewind if body.respond_to?(:rewind)
      end
    end
  end

  def self.parse(input)
    if input.is_a?(String)
      CGI.parse(input)
    else
      CGI.new(request: input).params
    end
  end
end
