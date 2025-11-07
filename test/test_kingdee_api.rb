# frozen_string_literal: true

require "test_helper"

class TestKingdeeApi < Minitest::Test
  def setup
    KingdeeApi.reset!
    KingdeeApi.configure do |config|
      config.client_id = "327910"
      config.client_secret = "c195564b8d1f1d4ad839ff83eea3eefa"
      config.app_key = "gsKeflPn"
      config.app_secret = "8b081c4ea0f9cbb569cf6f5c8f720774083e8f81"
      config.domain = "https://tf.jdy.com"
    end
  end

  def test_can_get_token
    skip "skip test_can_get_token"
    assert_equal "327910", KingdeeApi.client.client_id
    token = KingdeeApi.client.token
    assert token
  end

  def test_can_post_data
# https://api.kingdee.com/jdy/v2/bd/material
    response = KingdeeApi.client.post("/jdy/v2/bd/material", params: {

       "name": "名称1hello",
       "base_unit_id": '1'

    })
    assert response
  end

  def test_can_get_data
    skip "skip test_can_get_data"
    response = KingdeeApi.client.get("/jdy/v2/scm/pur_request")
    assert response
  end
end
