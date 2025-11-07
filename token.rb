#!/usr/bin/env ruby
require 'base64'
require 'openssl'
require 'uri'
require 'net/http'

class Token
  def self.call
    new.call
  end

  def initialize
  end

  def call
    app_key = 'gsKeflPn'
    app_secret = '8b081c4ea0f9cbb569cf6f5c8f720774083e8f81'
    client_secret = 'c195564b8d1f1d4ad839ff83eea3eefa'
    client_id = '327910'
    path = '/jdyconnector/app_management/kingdee_auth_token'


    puts '--------------------------------'
    puts 'app_signature'
    pp app_signature = app_signature_with(app_key, app_secret)
    puts '--------------------------------'
    puts 'X-Api-Signature:'
    params = {
      "app_key"       => app_key,
      "app_signature" => app_signature #app_signature
    }


    x_api_signature = x_api_signature_with(
      method: 'GET',
      path: path,
      params: params,
      nonce: nonce,
      timestamp: timestamp,
      client_secret: client_secret
    )

    query_token_with(app_key, app_signature, x_api_signature, nonce, timestamp, client_id)
  end

  def query_token_with(app_key, app_signature, x_api_signature, nonce, timestamp, client_id)

    # ✅ 构造请求 URL
    uri = URI('https://api.kingdee.com/jdyconnector/app_management/kingdee_auth_token')
    uri.query = URI.encode_www_form({
                                      "app_key"       => app_key,
                                      "app_signature" => app_signature #app_signature
                                    })

    pp uri.query
    pp uri.host
    pp uri.to_s
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

    puts "[HTTP] #{response.code}"
    puts response.body
  end

  def nonce
    @nonce ||= (Time.now.to_f * 1000).to_i.to_s
  end

  def timestamp
    @timestamp ||= (Time.now.to_f * 1000).to_i.to_s
  end

  def app_signature_with(app_key, app_secret)
    Base64.strict_encode64(
      OpenSSL::HMAC.hexdigest("SHA256", app_secret, app_key)
    )
  end

  def double_encode(str)
    URI.encode_www_form_component(
      URI.encode_www_form_component(str)
    ).gsub(/%[0-9a-f]{2}/) { |m| m.upcase }
  end

  # ✅ 生成 X-Api-Signature
  def x_api_signature_with(method:, path:, params:, nonce:, timestamp:, client_secret:)
    encoded_path = URI.encode_www_form_component(path)

    encoded_params = params.sort.to_h.map do |k, v|
      "#{double_encode(k)}=#{double_encode(v)}"
    end.join("&")

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

    puts sign_plain


    Base64.strict_encode64(
      OpenSSL::HMAC.hexdigest("SHA256", client_secret, sign_plain)
    )
  end


end


pp Token.call
pp '--------------------------------'
# pp Token.call == 'OTFiZTliNDFiMjNkYTI3YzVhNzg4MDI4ZGU3MWY1ZTA5ZTk1NjVlNGM1YTI1ZjIxY2Y5YTA3ZGY2OGI1MGQ1MQ=='
