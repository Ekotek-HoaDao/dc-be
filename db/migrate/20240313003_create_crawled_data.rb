# frozen_string_literal: true

class CreateCrawledData < ActiveRecord::Migration[7.0]
  def change
    create_table :crawled_data do |t|
      t.references :crawling_job, null: false, foreign_key: true
      t.text :url, null: false
      t.string :title
      t.string :content_type
      t.integer :status_code
      t.text :data # JSON string

      t.timestamps
    end

    add_index :crawled_data, [:crawling_job_id, :created_at]
    add_index :crawled_data, :url
    add_index :crawled_data, :status_code
  end
end
