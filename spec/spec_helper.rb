# frozen_string_literal: true
require_relative '../lib/formeze'
require 'i18n'
require 'mime-types'
require 'rack'

I18n.available_locales = [:en]
I18n.backend = I18n::Backend::Simple.new

def mock_request(body, content_type: 'multipart/form-data; boundary=AaB03x')
  env = Rack::MockRequest.env_for('/', {
    'REQUEST_METHOD' => 'POST',
    'CONTENT_TYPE' => content_type,
    'CONTENT_LENGTH' => body.bytesize.to_s,
    input: body
  })

  Rack::Request.new(env).tap(&:params)
end
