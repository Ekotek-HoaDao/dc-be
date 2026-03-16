# frozen_string_literal: true

# Create default admin user
admin_user = User.find_or_create_by(email: 'admin@dcbe.com') do |user|
  user.name = 'Admin User'
  user.password = 'password123'
  user.password_confirmation = 'password123'
end

puts "Created admin user: #{admin_user.email}"

# Create sample crawling job
crawling_job = admin_user.crawling_jobs.find_or_create_by(name: 'Sample News Crawl') do |job|
  job.url = 'https://news.ycombinator.com'
  job.description = 'Crawl Hacker News for latest tech news'
  job.max_pages = 5
  job.request_delay = 2000
  job.crawling_rules = {
    title: {
      type: 'css_selector',
      selector: '.titleline > a',
      extract: 'text',
      multiple: true
    },
    links: {
      type: 'css_selector', 
      selector: '.titleline > a',
      extract: 'attribute',
      attribute: 'href',
      multiple: true
    },
    scores: {
      type: 'css_selector',
      selector: '.score',
      extract: 'text', 
      multiple: true
    }
  }.to_json
end

puts "Created sample crawling job: #{crawling_job.name}"

puts "Seed data created successfully!"
