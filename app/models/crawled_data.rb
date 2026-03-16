# frozen_string_literal: true

class CrawledData < ApplicationRecord
  belongs_to :crawling_job
  has_one :user, through: :crawling_job

  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }
  validates :content_type, presence: true
  validates :status_code, presence: true, numericality: { greater_than: 0 }

  scope :successful, -> { where(status_code: 200..299) }
  scope :failed, -> { where.not(status_code: 200..299) }
  scope :by_content_type, ->(type) { where(content_type: type) }
  scope :recent, -> { order(created_at: :desc) }

  def successful?
    (200..299).include?(status_code)
  end

  def failed?
    !successful?
  end

  def parsed_data
    return {} unless data.present?
    
    JSON.parse(data)
  rescue JSON::ParserError
    {}
  end

  def parsed_data=(value)
    self.data = value.to_json
  end

  def size_in_kb
    return 0 unless data.present?
    
    (data.bytesize / 1024.0).round(2)
  end
end
