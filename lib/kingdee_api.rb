# frozen_string_literal: true

require "json"
require "net/http"
require "uri"
require "openssl"
require "base64"
require "securerandom"
require "digest"

require_relative "kingdee_api/version"
require_relative "kingdee_api/errors"
require_relative "kingdee_api/configuration"
require_relative "kingdee_api/signature"
require_relative "kingdee_api/request"
require_relative "kingdee_api/response"
require_relative "kingdee_api/http_adapter"
require_relative "kingdee_api/client"

module KingdeeApi
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset!
      @configuration = Configuration.new
    end

    def client(options = nil, **overrides)
      config = build_configuration(options, overrides)
      Client.new(config)
    end

    private

    def build_configuration(options, overrides)
      case options
      when Configuration
        options.dup
      when Hash
        configuration.dup.apply!(options.merge(overrides))
      else
        overrides.empty? ? configuration.dup : configuration.dup.apply!(overrides)
      end
    end
  end
end
