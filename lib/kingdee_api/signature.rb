# frozen_string_literal: true

module KingdeeApi
  module Signature

    SIGN_PATH = '/jdyconnector/app_management/kingdee_auth_token'
    TOKEN_CACHE_TTL = 24 * 60 * 60 # 24小时，单位：秒

    class << self
      attr_accessor :global_token_cache

      def reset_token_cache!
        @global_token_cache = nil
      end
    end

    def get_token
      # 检查缓存是否有效
      cached_token = get_cached_token
      return cached_token if cached_token

      # 缓存无效或不存在，获取新token
      app_signature = app_signature_with
      params = {
        "app_key"       => app_key,
        "app_signature" => app_signature
      }
      x_api_signature = x_api_signature_with(
        method: 'GET',
        path: SIGN_PATH,
        params: params,
        nonce: nonce,
        timestamp: timestamp,
        client_secret: client_secret
      )

      token = query_token_with(app_signature, x_api_signature)
      # 缓存token
      cache_token(token)
      token
    end

    private
    def query_token_with(app_signature, x_api_signature)
      # ✅ 构造请求 URL
      uri = URI('https://api.kingdee.com/jdyconnector/app_management/kingdee_auth_token')
      uri.query = URI.encode_www_form({
                                        "app_key"       => app_key,
                                        "app_signature" => app_signature #app_signature
                                      })

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(uri)
      request["X-Api-ClientID"]     = client_id
      request["X-Api-Auth-Version"] = "2.0"
      request["X-Api-TimeStamp"]    = timestamp
      request["X-Api-Nonce"]        = nonce
      request["X-Api-SignHeaders"]  = "X-Api-TimeStamp,X-Api-Nonce"
      request["X-Api-Signature"]    = "#{x_api_signature}"



      response = http.request(request)


      # app-token: object	false	用于调用星辰接口，有效期为24小时
      JSON.parse(response.body)["data"]["app-token"]
    end



    def x_api_signature_with(method:, path:, params:, nonce:, timestamp:, client_secret:)
      encoded_path = URI.encode_www_form_component(path)

      if params.nil? || params.empty?
        encoded_params = ''
      else
        encoded_params = params.sort.to_h.map do |k, v|
          "#{double_encode(k)}=#{double_encode(v)}"
        end.join("&")
      end

      headers_block = [
        "x-api-nonce:#{nonce}",
        "x-api-timestamp:#{timestamp}"
      ].join("\n")

      sign_plain = [
        method.upcase,
        encoded_path,
        encoded_params,
        headers_block,
        "" # ⚠️ 末尾必须换行
      ].join("\n")




      Base64.strict_encode64(
        OpenSSL::HMAC.hexdigest("SHA256", client_secret, sign_plain)
      )
    end
    def nonce
      @nonce ||= (Time.now.to_f * 1000).to_i.to_s
    end

    def timestamp
      @timestamp ||= (Time.now.to_f * 1000).to_i.to_s
    end

    def app_signature_with
      Base64.strict_encode64(
        OpenSSL::HMAC.hexdigest("SHA256", app_secret, app_key)
      )
    end

    def double_encode(str)
      URI.encode_www_form_component(
        URI.encode_www_form_component(str)
      ).gsub(/%[0-9a-f]{2}/) { |m| m.upcase }
    end

    def cache_token(token)
      KingdeeApi::Signature.global_token_cache = {
        token: token,
        cached_at: Time.now
      }
    end

    def get_cached_token
      token_cache = KingdeeApi::Signature.global_token_cache
      return nil unless token_cache

      cached_at = token_cache[:cached_at]
      return nil unless cached_at

      # 检查是否过期（24小时）
      elapsed_time = Time.now - cached_at
      return nil if elapsed_time >= TOKEN_CACHE_TTL

      token_cache[:token]
    end

  end
end
