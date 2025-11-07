# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "kingdee_api"

require "minitest/autorun"

Dir[File.expand_path("support/**/*.rb", __dir__)].sort.each { |file| require file }

module EnvHelpers
  def with_modified_env(values)
    original = {}
    values.each_key { |key| original[key] = ENV[key] }

    values.each { |key, value| ENV[key] = value }
    yield
  ensure
    original.each do |key, value|
      value.nil? ? ENV.delete(key) : ENV[key] = value
    end
  end
end

class Minitest::Test
  include EnvHelpers
end
