# frozen_string_literal: true

require "test_helper"

class SignatureTest < Minitest::Test
  def setup
    @configuration = KingdeeApi::Configuration.new.apply!(
      client_id: "cid",
      client_secret: "csecret",
      app_key: "akey",
      app_secret: "asecret",
      domain: "https://example.com"
    )
  end

  def test_generates_expected_headers
    request = KingdeeApi::Request.new(
      method: :post,
      path: "/foo/bar",
      params: { name: "kingdee", page: 1 },
      query: nil,
      headers: {},
      configuration: @configuration
    )
    request.prepare!

    signature = KingdeeApi::Signature.new(@configuration)
    timestamp = "1700000000000"

    SecureRandom.stub :alphanumeric, "nonce" do
      signature.stub :current_timestamp, timestamp do
        headers = signature.call(request)
        canonical_body = Digest::SHA256.hexdigest(JSON.generate(name: "kingdee", page: 1))
        canonical = [
          "POST",
          "/foo/bar",
          "",
          canonical_body,
          timestamp,
          "nonce",
          "csecret"
        ].join("\n")
        expected_signature = Base64.strict_encode64(
          OpenSSL::HMAC.digest("SHA256", "asecret", canonical)
        )

        assert_equal "Basic #{Base64.strict_encode64('cid:csecret')}", headers["Authorization"]
        assert_equal "akey", headers["X-Kd-App-Key"]
        assert_equal expected_signature, headers["X-Kd-Signature"]
      end
    end
  end
end
