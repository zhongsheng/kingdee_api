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


  end
end
