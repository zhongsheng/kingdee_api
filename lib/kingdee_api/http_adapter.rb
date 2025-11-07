# frozen_string_literal: true

module KingdeeApi
  class HttpAdapter
    def call(request, timeout: nil)
      http = build_http(request.uri, timeout || request.timeout)
      http.request(request.net_http_request)
    end

    private

    def build_http(uri, timeout)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = timeout[:open_timeout] if timeout[:open_timeout]
      http.read_timeout = timeout[:read_timeout] if timeout[:read_timeout]
      http
    end
  end
end
