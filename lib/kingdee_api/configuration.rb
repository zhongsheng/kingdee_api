# frozen_string_literal: true

module KingdeeApi
  class Configuration
    DEFAULT_DOMAIN = "https://api.kingdee.com"
    ATTRIBUTES = %i[
      client_id
      client_secret
      app_key
      app_secret
      domain
      open_timeout
      read_timeout
      logger
    ].freeze
    REQUIRED = %i[client_id client_secret app_key app_secret domain].freeze

    attr_accessor :client_id, :client_secret, :app_key, :app_secret, :logger
    attr_reader :domain, :open_timeout, :read_timeout

    def initialize
      reset!
    end

    def reset!
      self.client_id = ENV["KINGDEE_CLIENT_ID"]
      self.client_secret = ENV["KINGDEE_CLIENT_SECRET"]
      self.app_key = ENV["KINGDEE_APP_KEY"]
      self.app_secret = ENV["KINGDEE_APP_SECRET"]
      self.domain = ENV["KINGDEE_DOMAIN"]
      self.open_timeout = ENV.fetch("KINGDEE_OPEN_TIMEOUT", 5)
      self.read_timeout = ENV.fetch("KINGDEE_READ_TIMEOUT", 30)
      self.logger = nil
    end

    def dup
      self.class.new.apply!(to_h)
    end
    alias clone dup

    def apply!(attributes)
      return self if attributes.nil?

      attributes.each do |key, value|
        writer = "#{key}="
        next unless respond_to?(writer)

        public_send(writer, value)
      end
      self
    end

    def to_h
      ATTRIBUTES.each_with_object({}) do |key, memo|
        value = public_send(key)
        memo[key] = value unless value.nil?
      end
    end

    def validate!
      missing = REQUIRED.reject { |name| present?(public_send(name)) }
      return true if missing.empty?

      raise ConfigurationError, "Missing configuration: #{missing.join(', ')}"
    end

    def domain=(value)
      sanitized = value.to_s.strip
      sanitized = nil if sanitized.empty?
      sanitized ||= DEFAULT_DOMAIN
      @domain = sanitized.chomp("/")
    end

    def open_timeout=(value)
      @open_timeout = normalize_timeout(value, default: 5)
    end

    def read_timeout=(value)
      @read_timeout = normalize_timeout(value, default: 30)
    end

    private

    def normalize_timeout(value, default:)
      Integer(value)
    rescue ArgumentError, TypeError
      default
    end

    def present?(value)
      !(value.nil? || (value.respond_to?(:empty?) && value.empty?))
    end
  end
end
