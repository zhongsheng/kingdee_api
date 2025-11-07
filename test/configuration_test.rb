# frozen_string_literal: true

require "test_helper"

class ConfigurationTest < Minitest::Test
  def test_reads_defaults_from_environment
    with_modified_env(
      "KINGDEE_CLIENT_ID" => "cid",
      "KINGDEE_CLIENT_SECRET" => "csecret",
      "KINGDEE_APP_KEY" => "akey",
      "KINGDEE_APP_SECRET" => "asecret",
      "KINGDEE_DOMAIN" => "https://tf.jdy.com",
      "KINGDEE_OPEN_TIMEOUT" => "4",
      "KINGDEE_READ_TIMEOUT" => "10"
    ) do
      config = KingdeeApi::Configuration.new

      assert_equal "cid", config.client_id
      assert_equal "csecret", config.client_secret
      assert_equal "akey", config.app_key
      assert_equal "asecret", config.app_secret
      assert_equal "https://tf.jdy.com", config.domain
      assert_equal 4, config.open_timeout
      assert_equal 10, config.read_timeout
    end
  end

  def test_validate_raises_when_required_values_missing
    config = KingdeeApi::Configuration.new
    config.client_id = nil

    assert_raises(KingdeeApi::ConfigurationError) { config.validate! }
  end

  def test_dup_creates_an_isolated_copy
    config = KingdeeApi::Configuration.new
    config.apply!(
      client_id: "cid",
      client_secret: "secret",
      app_key: "app",
      app_secret: "asecret",
      domain: "https://example.com"
    )
    copy = config.dup
    copy.client_id = "override"

    refute_equal config.client_id, copy.client_id
  end
end
