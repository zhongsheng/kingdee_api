# frozen_string_literal: true

class FakeHttpAdapter
  attr_reader :requests

  def initialize(status: 200, headers: {}, body: '{"code":0}')
    @requests = []
    @response = FakeResponse.new(status, headers, body)
  end

  def call(request, timeout: nil)
    requests << { request: request, timeout: timeout }
    @response
  end

  def last_request
    requests.last
  end

  class FakeResponse
    attr_reader :code, :body

    def initialize(status, headers, body)
      @code = status.to_i.to_s
      @headers = headers
      @body = body
    end

    def each_header
      return enum_for(:each_header) unless block_given?

      @headers.each { |key, value| yield(key, value) }
    end
  end
end
