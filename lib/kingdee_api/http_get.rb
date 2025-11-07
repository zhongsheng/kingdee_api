# frozen_string_literal: true

module KingdeeApi
  module HttpGet

    HOST = 'https://api.kingdee.com'


    def get(path, params = nil)
      query_with(path, params)
    end

    private
    def query_with(path, params)
      # ✅ 构造请求 URL
      uri = URI("#{HOST}#{path}")
      uri.query = URI.encode_www_form(params) unless params.nil?

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      x_api_signature = x_api_signature_with(
        method: 'GET',
        path: path,
        params: params,
        nonce: nonce,
        timestamp: timestamp,
        client_secret: client_secret
      )

      request = Net::HTTP::Get.new(uri)
      request["Content-Type"] = "application/json"
      request["X-Api-ClientID"]     = client_id
      request["X-Api-Auth-Version"] = "2.0"
      request["X-Api-TimeStamp"]    = timestamp
      request["X-Api-SignHeaders"]  = "X-Api-TimeStamp,X-Api-Nonce"
      request["X-Api-Nonce"]        = nonce
      request["X-Api-Signature"]    = "#{x_api_signature}"
      request["app-token"]    = token
      request["X-GW-Router-Addr"] = domain




      response = http.request(request)

      pp response.body
      puts "[HTTP] #{response.code}"
      # puts JSON.parse(response.body)
      # app-token: object	false	用于调用星辰接口，有效期为24小时
      response.body
    end






  end
end
