# frozen_string_literal: true

module Crawling
  class CrawlService < BaseService
    def call
      log_info("Starting crawl for job: #{job.name} (#{job.id})")
      
      begin
        job.update(status: 'running', started_at: Time.current)
        
        crawl_url(job.url)
        
        job.update(status: 'completed', finished_at: Time.current)
        log_info("Crawl completed for job: #{job.name}")
        
      rescue StandardError => e
        add_error("Crawl failed: #{e.message}")
        job.update(status: 'failed', finished_at: Time.current)
        log_info("Crawl failed for job: #{job.name}")
      end
      
      success?
    end

    private

    def crawl_url(url)
      log_debug("Crawling URL: #{url}")
      
      response = http_client.get(url)
      
      unless response.success?
        add_error("HTTP request failed for #{url}: #{response.code}")
        return
      end

      content_type = response.headers['content-type']&.split(';')&.first || 'text/html'
      
      parsed_data = parse_content(response.body, content_type, url)
      
      # Save crawled data
      crawled_data = job.crawled_data.create!(
        url: url,
        title: parsed_data[:title] || extract_title_from_url(url),
        content_type: content_type,
        status_code: response.code,
        data: parsed_data
      )

      log_debug("Saved crawled data: #{crawled_data.id}")
      
      # Extract and crawl additional URLs if needed
      crawl_additional_urls(parsed_data, url) if should_crawl_additional_urls?

    rescue StandardError => e
      add_error("Failed to crawl #{url}: #{e.message}")
    end

    def parse_content(content, content_type, url)
      case content_type.downcase
      when 'text/html', 'application/xhtml+xml'
        parser.parse_html(content, url)
      when 'application/json'
        parser.parse_json(content)
      when 'application/xml', 'text/xml'
        parser.parse_xml(content)
      else
        { raw_content: content.truncate(10000), content_type: content_type }
      end
    end

    def crawl_additional_urls(parsed_data, base_url)
      return unless parsed_data[:links].present?
      
      crawled_count = job.crawled_data.count
      max_pages = job.max_pages || 100
      
      return if crawled_count >= max_pages

      internal_links = parsed_data[:links].select { |link| link[:internal] }
      links_to_crawl = internal_links.first(max_pages - crawled_count)
      
      links_to_crawl.each do |link|
        next if already_crawled?(link[:url])
        
        break if job.reload.status != 'running' # Check if job was paused/stopped
        
        crawl_url(link[:url])
      end
    end

    def should_crawl_additional_urls?
      job.max_pages.to_i > 1
    end

    def already_crawled?(url)
      job.crawled_data.exists?(url: url)
    end

    def extract_title_from_url(url)
      URI.parse(url).path.split('/').last || 'Unknown'
    rescue
      'Unknown'
    end
  end
end
