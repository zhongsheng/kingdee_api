# frozen_string_literal: true

module KingdeeApi
  class Client
    SUPPORTED_METHODS = %i[get post put patch delete].freeze
    include Signature
    def token
      @token ||= get_token
    end

    def initialize(configuration, signer: nil, http_adapter: nil)
      @configuration = coerce_configuration(configuration)
      @configuration.validate!

      @http_adapter = http_adapter || HttpAdapter.new
    end

    SUPPORTED_METHODS.each do |verb|
      define_method(verb) do |path, **options, &block|
        execute(verb, path, **options, &block)
      end
    end

    def execute(method, path, params: nil, query: nil, headers: {}, timeout: nil, &block)
      request = Request.new(
        method: method,
        path: path,
        params: params,
        query: query,
        headers: headers,
        configuration: configuration
      )

      yield(request) if block_given?
      request.prepare!
      request.headers.merge!(signer.call(request))

      raw_response = http_adapter.call(request, timeout: timeout)
      Response.new(raw_response)
    end

    private

    attr_reader :configuration, :signer, :http_adapter

    def coerce_configuration(config)
      return config if config.is_a?(Configuration)

      Configuration.new.apply!(config || {})
    end
  end
end
