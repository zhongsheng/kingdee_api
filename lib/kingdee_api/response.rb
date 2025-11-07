# frozen_string_literal: true

module KingdeeApi
  class Response
    attr_reader :status, :body, :headers

    def initialize(http_response)
      @status = http_response.code.to_i
      @headers = extract_headers(http_response)
      @raw_body = http_response.body
      @body = parse_body(@raw_body)
    end

    def success?
      (200..299).include?(status)
    end

    def error_message
      return nil if success?

      if body.is_a?(Hash)
        body["message"] || body["msg"] || body["error"] || body["error_description"]
      end
    end

    def raw_body
      @raw_body
    end

    private

    def parse_body(payload)
      return nil if payload.nil? || payload.empty?

      JSON.parse(payload)
    rescue JSON::ParserError
      payload
    end

    def extract_headers(response)
      response.each_header.each_with_object({}) do |(key, value), memo|
        memo[key] = value
      end
    end
  end
end
