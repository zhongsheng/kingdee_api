# frozen_string_literal: true

module KingdeeApi
  module Request
    HOST = 'https://api.kingdee.com'

    def get(path, params: nil)
      if not params.nil?
        params = params.sort.to_h
      end

      uri = URI("#{HOST}#{path}")
      uri.query = URI.encode_www_form(params) unless params.nil?
      data = Net::HTTP.get(uri, get_headers_with(path, params: ))

      JSON.parse(data)
    end


    def post(path, params: nil)
      uri = URI("#{HOST}#{path}")
      response = Net::HTTP.post(uri, JSON.generate(params.sort.to_h), post_headers_with(path))

      JSON.parse(response.body)
    end

    private

    def base_headers
      {
        "Content-Type" => "application/json",
        "X-Api-ClientID" => client_id,
        "X-Api-Auth-Version" => "2.0",
        "X-Api-TimeStamp" => timestamp,
        "X-Api-SignHeaders" => "X-Api-TimeStamp,X-Api-Nonce",
        "X-Api-Nonce" => nonce,
        "X-Api-Signature" => 'placeholder',
        "app-token" => token,
        "X-GW-Router-Addr" => domain
      }
    end

    def get_headers_with(path, params: nil)
      x_api_signature = x_api_signature_with(
        method: 'GET',
        path: path,
        params: params,
        nonce: nonce,
        timestamp: timestamp,
        client_secret: client_secret
      )

      base_headers.merge("X-Api-Signature" => x_api_signature)
    end
    def post_headers_with(path)
      x_api_signature = x_api_signature_with(
        method: 'POST',
        path: path,
        params: nil,
        nonce: nonce,
        timestamp: timestamp,
        client_secret: client_secret
      )
      base_headers.merge("X-Api-Signature" => x_api_signature)
    end


    # todo remove
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
