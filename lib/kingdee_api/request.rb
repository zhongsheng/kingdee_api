# frozen_string_literal: true

module KingdeeApi
  class Request
    Attachment = Struct.new(:name, :filename, :content_type, :data, keyword_init: true)

    attr_reader :method, :path, :params, :query, :headers, :attachments, :configuration

    def initialize(method:, path:, params:, query:, headers:, configuration:)
      @method = method.to_s.downcase.to_sym
      @path = normalize_path(path)
      @params = params || {}
      @query = query
      @headers = default_headers.merge(normalize_headers(headers))
      @attachments = []
      @configuration = configuration
      @prepared = false
    end

    def attach(file_path = nil, name: nil, filename: nil, content_type: nil, io: nil, data: nil)
      payload = data || read_attachment_data(file_path, io)
      filename ||= File.basename(file_path) if file_path
      filename ||= "attachment-#{attachments.size + 1}"
      name ||= "file#{attachments.size + 1}"
      content_type ||= "application/octet-stream"
      attachments << Attachment.new(
        name: name,
        filename: filename,
        content_type: content_type,
        data: payload
      )
      self
    end

    def prepare!
      return self if prepared?

      @prepared = true
      payload = body
      headers["Content-Type"] = content_type if payload
      headers["Accept"] ||= "application/json"
      self
    end

    def prepared?
      @prepared
    end

    def uri
      @uri ||= begin
        base = configuration.domain || Configuration::DEFAULT_DOMAIN
        normalized_base = base.end_with?("/") ? base : "#{base}/"
        built = URI.parse(normalized_base + path.delete_prefix("/"))
        qs = query_string_for_signature
        built.query = qs unless qs.empty?
        built
      end
    end

    def query_string_for_signature
      @query_string_for_signature ||= encode_params(query_params)
    end

    def body
      return @body if defined?(@body)

      if body_required?
        @body = multipart? ? build_multipart_body : encode_body(params_for_body)
      else
        @body = nil
      end
    end

    def body_digest
      body_value = body
      return "" if body_value.nil?

      Digest::SHA256.hexdigest(body_value)
    end

    def content_type
      @content_type ||= multipart? ? "multipart/form-data; boundary=#{boundary}" : "application/json"
    end

    def path_for_signature
      path
    end

    def timeout
      {
        open_timeout: configuration.open_timeout,
        read_timeout: configuration.read_timeout
      }
    end

    def net_http_request
      prepare!
      request = net_http_class.new(uri)
      headers.each { |key, value| request[key] = value }
      request.body = body if body
      request
    end

    private

    def params_for_body
      return {} unless params
      params
    end

    def query_params
      explicit_query = query || {}
      return explicit_query unless explicit_query.empty?
      use_params_as_query? ? params : {}
    end

    def use_params_as_query?
      %i[get delete].include?(method)
    end

    def body_required?
      return true if multipart?
      return false if %i[get delete].include?(method) && params_for_body.empty?

      true
    end

    def multipart?
      attachments.any?
    end

    def boundary
      @boundary ||= "KingdeeApiBoundary#{SecureRandom.hex(8)}"
    end

    def encode_body(payload)
      return nil if payload.nil?

      JSON.generate(payload)
    end

    def encode_params(payload)
      return "" if payload.nil? || payload.empty?

      URI.encode_www_form(flatten_params(payload))
    end

    def flatten_params(value, prefix = nil, pairs = [])
      case value
      when Hash
        value.each do |key, nested|
          new_prefix = prefix ? "#{prefix}[#{key}]" : key.to_s
          flatten_params(nested, new_prefix, pairs)
        end
      when Array
        value.each_with_index do |nested, index|
          new_prefix = "#{prefix}[#{index}]"
          flatten_params(nested, new_prefix, pairs)
        end
      else
        raise RequestError, "Unnamed parameter detected" if prefix.nil?

        pairs << [prefix, value]
      end
      pairs
    end

    def build_multipart_body
      buffer = +""
      flatten_params(params_for_body).each do |(key, value)|
        buffer << "--#{boundary}\r\n"
        buffer << %(Content-Disposition: form-data; name="#{key}"\r\n\r\n)
        buffer << "#{value}\r\n"
      end

      attachments.each do |attachment|
        buffer << "--#{boundary}\r\n"
        buffer << %(Content-Disposition: form-data; name="#{attachment.name}"; filename="#{attachment.filename}"\r\n)
        buffer << "Content-Type: #{attachment.content_type}\r\n\r\n"
        buffer << attachment.data.to_s
        buffer << "\r\n"
      end

      buffer << "--#{boundary}--\r\n"
      buffer
    end

    def net_http_class
      case method
      when :get then Net::HTTP::Get
      when :post then Net::HTTP::Post
      when :put then Net::HTTP::Put
      when :patch then Net::HTTP::Patch
      when :delete then Net::HTTP::Delete
      else
        raise RequestError, "Unsupported HTTP method: #{method}"
      end
    end

    def normalize_path(raw_path)
      raw = raw_path.to_s.strip
      raw.start_with?("/") ? raw : "/#{raw}"
    end

    def normalize_headers(custom_headers)
      (custom_headers || {}).each_with_object({}) do |(key, value), memo|
        memo[key.to_s] = value
      end
    end

    def default_headers
      {
        "User-Agent" => "kingdee_api/#{KingdeeApi::VERSION}",
        "Content-Type" => "application/json"
      }
    end

    def read_attachment_data(file_path, io)
      if io
        io.respond_to?(:read) ? io.read : io.to_s
      elsif file_path && File.file?(file_path)
        File.binread(file_path)
      else
        raise RequestError, "Attachment must provide a file_path or IO-like object"
      end
    end
  end
end
