# frozen_string_literal: true

class CrawlingJobSerializer < BaseSerializer
  def as_json
    {
      id: object.id,
      name: object.name,
      url: object.url,
      description: object.description,
      status: object.status,
      schedule_type: object.schedule_type,
      schedule_value: object.schedule_value,
      max_pages: object.max_pages,
      request_delay: object.request_delay,
      enabled: object.enabled,
      crawling_rules: object.crawling_rules_json,
      started_at: object.started_at,
      finished_at: object.finished_at,
      duration: object.duration,
      data_count: object.crawled_data.count,
      created_at: object.created_at,
      updated_at: object.updated_at
    }
  end
end
