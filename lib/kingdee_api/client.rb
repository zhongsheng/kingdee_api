# frozen_string_literal: true

module KingdeeApi
  class Client
    SUPPORTED_METHODS = %i[get post put patch delete].freeze

    include Signature
    include Request

    attr_reader :configuration
    attr_reader :app_key
    attr_reader :app_secret
    attr_reader :client_id
    attr_reader :client_secret
    attr_reader :domain

    def token
      @token ||= get_token
    end

    def initialize(configuration, signer: nil, http_adapter: nil)
      @configuration = coerce_configuration(configuration)
      @configuration.validate!
      @app_key = configuration.app_key
      @app_secret = configuration.app_secret
      @client_id = configuration.client_id
      @client_secret = configuration.client_secret
      @domain = configuration.domain
    end



    private

    attr_reader :configuration, :signer, :http_adapter

    def coerce_configuration(config)
      return config if config.is_a?(Configuration)

      Configuration.new.apply!(config || {})
    end
  end
end
