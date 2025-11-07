# frozen_string_literal: true

module KingdeeApi
  class Error < StandardError; end

  class ConfigurationError < Error; end

  class RequestError < Error; end
end
