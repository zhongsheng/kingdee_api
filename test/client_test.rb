# frozen_string_literal: true

require "test_helper"

class ClientTest < Minitest::Test
  def setup
    @configuration = KingdeeApi::Configuration.new.apply!(
      client_id: "cid",
      client_secret: "csecret",
      app_key: "akey",
      app_secret: "asecret",
      domain: "https://example.com"
    )
  end

  def test_get_request_builds_query_params
    adapter = FakeHttpAdapter.new
    signer = StubSigner.new
    client = KingdeeApi::Client.new(@configuration, http_adapter: adapter, signer: signer)

    response = client.get("jdy/v2/bill", params: { page: 2 })

    assert response.success?
    captured = adapter.last_request.fetch(:request)
    assert_equal "/jdy/v2/bill", captured.path_for_signature
    assert_equal "page=2", captured.query_string_for_signature
    assert_equal "ok", signer.last_headers["X-Test"]
  end

  def test_post_request_supports_attachments
    adapter = FakeHttpAdapter.new
    signer = StubSigner.new
    client = KingdeeApi::Client.new(@configuration, http_adapter: adapter, signer: signer)

    client.post("/upload", params: { bill_date: "2024-01-01" }) do |request|
      request.attach(nil, data: "file content", filename: "file.txt")
    end

    captured = adapter.last_request.fetch(:request)
    assert_includes captured.headers["Content-Type"], "multipart/form-data"
  end

  def test_timeout_can_be_overridden_per_request
    adapter = FakeHttpAdapter.new
    signer = StubSigner.new
    client = KingdeeApi::Client.new(@configuration, http_adapter: adapter, signer: signer)

    client.post("/override", params: { foo: "bar" }, timeout: { read_timeout: 5, open_timeout: 1 })

    timeout = adapter.last_request.fetch(:timeout)
    assert_equal 5, timeout[:read_timeout]
    assert_equal 1, timeout[:open_timeout]
  end

  class StubSigner
    attr_reader :last_headers

    def call(_request)
      @last_headers = { "X-Test" => "ok" }
    end
  end
end
