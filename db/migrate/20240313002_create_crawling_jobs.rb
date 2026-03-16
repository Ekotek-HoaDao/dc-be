# frozen_string_literal: true

class CreateCrawlingJobs < ActiveRecord::Migration[7.0]
  def change
    create_table :crawling_jobs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :url, null: false
      t.text :description
      t.string :status, default: 'pending'
      t.string :schedule_type # once, daily, weekly, monthly
      t.string :schedule_value # cron expression or specific values
      t.integer :max_pages, default: 100
      t.integer :request_delay, default: 1000 # milliseconds
      t.boolean :enabled, default: true
      t.text :crawling_rules # JSON string
      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps
    end

    add_index :crawling_jobs, [:user_id, :status]
    add_index :crawling_jobs, :status
  end
end
