# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  has_many :crawling_jobs, dependent: :destroy
  has_many :crawled_data, through: :crawling_jobs

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  before_save :downcase_email

  scope :active, -> { where(active: true) }

  def full_name
    name
  end

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
