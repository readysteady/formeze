# frozen_string_literal: true
require 'rack'

module Formeze::FormData
  def self.parse(input)
    if input.is_a?(String)
      query_parser.parse_query(input)
    elsif input.respond_to?(:env)
      body = input.body
      body.rewind if body.respond_to?(:rewind)
      case input.media_type
      when 'multipart/form-data'
        Rack::Multipart.parse_multipart(input.env, Params)
      when 'application/x-www-form-urlencoded'
        query_parser.parse_query(body.read)
      else
        raise ArgumentError, "can't parse #{input.media_type.inspect} form data"
      end
    else
      raise ArgumentError, "can't parse #{input.class} form data"
    end
  end

  module Params
    def self.make_params
      ParamsHash.new { |h, k| h[k] = Array.new }
    end

    def self.normalize_params(params, key, value)
      if value.is_a?(Hash)
        value = Rack::Multipart::UploadedFile.new(io: value[:tempfile], filename: value[:filename], content_type: value[:type])
      end

      params[key] << value
    end
  end

  class ParamsHash < ::Hash
    alias_method :to_params_hash, :to_h
  end

  class QueryParser < Rack::QueryParser
    def make_params
      Hash.new { |h, k| h[k] = Array.new }
    end
  end

  def self.query_parser
    @query_parser ||= QueryParser.new(nil, 0)
  end

  private_class_method :query_parser
end
