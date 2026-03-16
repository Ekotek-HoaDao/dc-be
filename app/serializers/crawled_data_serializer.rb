# frozen_string_literal: true

class CrawledDataSerializer < BaseSerializer
  def as_json
    {
      id: object.id,
      url: object.url,
      title: object.title,
      content_type: object.content_type,
      status_code: object.status_code,
      data: object.parsed_data,
      size_kb: object.size_in_kb,
      successful: object.successful?,
      crawling_job: {
        id: object.crawling_job.id,
        name: object.crawling_job.name
      },
      created_at: object.created_at,
      updated_at: object.updated_at
    }
  end
end
