# frozen_string_literal: true

module KingdeeApi
  module Signature
    CANONICAL_SEPARATOR = "\n"

    def get_token

    end

    private

    attr_reader :configuration

    def canonical_string(request, timestamp, nonce)
      [
        request.method.to_s.upcase,
        request.path_for_signature,
        request.query_string_for_signature,
        request.body_digest,
        timestamp,
        nonce,
        configuration.client_secret
      ].join(CANONICAL_SEPARATOR)
    end

    def authorization_token
      Base64.strict_encode64("#{configuration.client_id}:#{configuration.client_secret}")
    end

    def current_timestamp
      (Time.now.utc.to_f * 1000).to_i.to_s
    end
  end
end
