# frozen_string_literal: true

class CrawlingJob < ApplicationRecord
  belongs_to :user
  has_many :crawled_data, dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }
  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }
  validates :status, presence: true, inclusion: { in: %w[pending running paused completed stopped failed] }
  validates :schedule_type, inclusion: { in: %w[once daily weekly monthly] }, allow_blank: true
  validates :max_pages, numericality: { greater_than: 0, less_than_or_equal_to: 10000 }, allow_blank: true
  validates :request_delay, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true

  before_validation :set_default_status, on: :create
  before_validation :set_default_values

  scope :enabled, -> { where(enabled: true) }
  scope :by_status, ->(status) { where(status: status) }
  scope :scheduled, -> { where.not(schedule_type: nil) }

  def can_start?
    %w[pending stopped failed].include?(status)
  end

  def running?
    status == 'running'
  end

  def paused?
    status == 'paused'
  end

  def completed?
    status == 'completed'
  end

  def failed?
    status == 'failed'
  end

  def duration
    return nil unless started_at && finished_at
    
    finished_at - started_at
  end

  def crawling_rules_json
    return {} unless crawling_rules.present?
    
    JSON.parse(crawling_rules)
  rescue JSON::ParserError
    {}
  end

  def crawling_rules_json=(value)
    self.crawling_rules = value.to_json
  end

  private

  def set_default_status
    self.status ||= 'pending'
  end

  def set_default_values
    self.max_pages ||= 100
    self.request_delay ||= 1000
    self.enabled = true if enabled.nil?
  end
end
