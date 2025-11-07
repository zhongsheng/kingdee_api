# frozen_string_literal: true

module KingdeeApi
  module Request
    HOST = 'https://api.kingdee.com'

    def get(path, params: nil)
      query_with('GET', path: path, params: params)
    end

    # TODO: 实现 post 方法
    def post(path, params: nil)
      pp "post", query_with('POST', path: path, params: params)
    end

    private
    def query_with(method, path:, params: nil)
      # ✅ 构造请求 URL
      uri = URI("#{HOST}#{path}")
      uri.query = URI.encode_www_form(params) unless params.nil? || method == 'POST'

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      x_api_signature = x_api_signature_with(
        method: method,
        path: path,
        params: method == 'POST' ? {} : params,
        nonce: nonce,
        timestamp: timestamp,
        client_secret: client_secret
      )

      request_class = Net::HTTP.const_get(method.capitalize)
      request = request_class.new(uri)
      request["Content-Type"] = "application/json"
      request["X-Api-ClientID"]     = client_id
      request["X-Api-Auth-Version"] = "2.0"
      request["X-Api-TimeStamp"]    = timestamp
      request["X-Api-SignHeaders"]  = "X-Api-TimeStamp,X-Api-Nonce"
      request["X-Api-Nonce"]        = nonce
      request["X-Api-Signature"]    = "#{x_api_signature}"
      request["app-token"]    = token
      request["X-GW-Router-Addr"] = domain

      if method == 'POST'
        # 参数名ASCII码升序顺序进行排序
        pp "--------------------------------"
        pp params
        pp JSON.generate(params.sort.to_h)
        pp "--------------------------------"
        request.body = JSON.generate(params.sort.to_h)
      end
# 打印请求头 和 body
      pp "request headers: #{request.to_hash}"
      pp "request body: #{request.body}"
      response = http.request(request)


      pp response.body
      puts "[HTTP] #{response.code}"
      if response.code == '200'
        return JSON.parse(response.body)
      else
        raise JSON.parse(response.body).fetch('description', 'Unknown error')
      end
    end
  end
end
