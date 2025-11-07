# frozen_string_literal: true

require "test_helper"

class TestKingdeeApi < Minitest::Test
  def setup
    KingdeeApi.reset!
    # KingdeeApi.configure do |config|
    #   config.client_id = "327910"
    #   config.client_secret = "c195564b8d1f1d4ad839ff83eea3eefa"
    #   config.app_key = "gsKeflPn"
    #   config.app_secret = "8b081c4ea0f9cbb569cf6f5c8f720774083e8f81"
    #   config.domain = "https://tf.jdy.com"
    # end
  end

  def test_can_get_token
    assert_equal "327910", KingdeeApi.client.client_id
    assert_equal "c195564b8d1f1d4ad839ff83eea3eefa", KingdeeApi.client.client_secret
    assert_equal "gsKeflPn", KingdeeApi.client.app_key
    assert_equal "8b081c4ea0f9cbb569cf6f5c8f720774083e8f81", KingdeeApi.client.app_secret
    assert_equal "https://tf.jdy.com", KingdeeApi.client.domain

    token = KingdeeApi.client.token
    assert token
  end

  def test_can_post_data

    response = KingdeeApi.client.post("/jdy/v2/bd/material", params: {

       "name": Random.alphanumeric(10),
       "base_unit_id": '1'

    })
    assert response
  end

  def test_can_get_data
    # skip "skip test_can_get_data"
    response = KingdeeApi.client.get("/jdy/v2/scm/pur_request", params: {
      order_by: 'number asc',
      pur_chase_status: 'A'
    })
    assert response
  end
end
