# frozen_string_literal: true

class CrawlingWorker
  include Sidekiq::Worker
  
  sidekiq_options retry: 3, backtrace: true

  def perform(crawling_job_id)
    crawling_job = CrawlingJob.find(crawling_job_id)
    
    return unless crawling_job.can_start?
    
    crawl_service = Crawling::CrawlService.new(crawling_job)
    
    if crawl_service.call
      Rails.logger.info("Crawling job #{crawling_job_id} completed successfully")
    else
      Rails.logger.error("Crawling job #{crawling_job_id} failed: #{crawl_service.error_messages}")
    end
    
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error("Crawling job #{crawling_job_id} not found")
  rescue StandardError => e
    Rails.logger.error("Crawling worker error: #{e.message}")
    raise
  end
end
