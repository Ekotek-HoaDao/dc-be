# frozen_string_literal: true

module Crawling
  class HttpClient
    include HTTParty

    def initialize(timeout: 30, delay: 1000, user_agent: 'DCBot/1.0', retries: 3)
      @timeout = timeout
      @delay = delay / 1000.0 # Convert to seconds
      @user_agent = user_agent
      @retries = retries
      @last_request_time = nil

      setup_httparty_options
    end

    def get(url, options = {})
      enforce_rate_limit
      
      response = self.class.get(url, build_options(options))
      
      log_request(url, response)
      response
    rescue StandardError => e
      Rails.logger.error("HTTP Request failed for #{url}: #{e.message}")
      raise
    end

    def post(url, options = {})
      enforce_rate_limit
      
      response = self.class.post(url, build_options(options))
      
      log_request(url, response)
      response
    rescue StandardError => e
      Rails.logger.error("HTTP Request failed for #{url}: #{e.message}")
      raise
    end

    private

    attr_reader :timeout, :delay, :user_agent, :retries

    def setup_httparty_options
      self.class.timeout @timeout
      self.class.headers 'User-Agent' => @user_agent
      self.class.headers 'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
      self.class.headers 'Accept-Language' => 'en-US,en;q=0.5'
      self.class.headers 'Accept-Encoding' => 'gzip, deflate'
      self.class.headers 'Connection' => 'keep-alive'
    end

    def build_options(options)
      default_options = {
        timeout: @timeout,
        headers: additional_headers(options[:headers] || {}),
        follow_redirects: true,
        limit: 5
      }

      default_options.merge(options.except(:headers))
    end

    def additional_headers(custom_headers)
      base_headers = {
        'Cache-Control' => 'no-cache',
        'Pragma' => 'no-cache'
      }

      base_headers.merge(custom_headers)
    end

    def enforce_rate_limit
      return unless @last_request_time && @delay > 0

      time_since_last_request = Time.current - @last_request_time
      sleep_time = @delay - time_since_last_request

      if sleep_time > 0
        Rails.logger.debug("Rate limiting: sleeping for #{sleep_time} seconds")
        sleep(sleep_time)
      end

      @last_request_time = Time.current
    end

    def log_request(url, response)
      status = response&.code || 'N/A'
      size = response&.body&.bytesize || 0
      
      Rails.logger.info("HTTP #{response&.request&.http_method} #{url} - #{status} - #{size} bytes")
    end
  end
end
