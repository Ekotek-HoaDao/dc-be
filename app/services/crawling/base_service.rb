# frozen_string_literal: true

module Crawling
  class BaseService
    attr_reader :job, :errors

    def initialize(crawling_job)
      @job = crawling_job
      @errors = []
    end

    def call
      raise NotImplementedError, 'Subclasses must implement call method'
    end

    def success?
      @errors.empty?
    end

    def error_messages
      @errors
    end

    protected

    def add_error(message)
      @errors << message
      Rails.logger.error("[#{self.class.name}] #{message}")
    end

    def log_info(message)
      Rails.logger.info("[#{self.class.name}] #{message}")
    end

    def log_debug(message)
      Rails.logger.debug("[#{self.class.name}] #{message}")
    end

    private

    def http_client
      @http_client ||= Crawling::HttpClient.new(
        timeout: 30,
        delay: job.request_delay || 1000,
        user_agent: ENV.fetch('USER_AGENT', 'DCBot/1.0')
      )
    end

    def parser
      @parser ||= Crawling::Parser.new(job.crawling_rules_json)
    end
  end
end
