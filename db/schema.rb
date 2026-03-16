# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 20240313003) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "crawled_data", force: :cascade do |t|
    t.bigint "crawling_job_id", null: false
    t.text "url", null: false
    t.string "title"
    t.string "content_type"
    t.integer "status_code"
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["crawling_job_id", "created_at"], name: "index_crawled_data_on_crawling_job_id_and_created_at"
    t.index ["crawling_job_id"], name: "index_crawled_data_on_crawling_job_id"
    t.index ["status_code"], name: "index_crawled_data_on_status_code"
    t.index ["url"], name: "index_crawled_data_on_url"
  end

  create_table "crawling_jobs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.text "url", null: false
    t.text "description"
    t.string "status", default: "pending"
    t.string "schedule_type"
    t.string "schedule_value"
    t.integer "max_pages", default: 100
    t.integer "request_delay", default: 1000
    t.boolean "enabled", default: true
    t.text "crawling_rules"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_crawling_jobs_on_status"
    t.index ["user_id", "status"], name: "index_crawling_jobs_on_user_id_and_status"
    t.index ["user_id"], name: "index_crawling_jobs_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "crawled_data", "crawling_jobs"
  add_foreign_key "crawling_jobs", "users"
end
