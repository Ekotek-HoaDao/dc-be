# frozen_string_literal: true

# Sidekiq Web UI configuration
if Rails.env.development?
  require 'sidekiq/web'
  
  # Optional: Add basic authentication for Sidekiq::Web
  # Uncomment below if you want password protection
  # Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  #   username == 'admin' && password == 'sidekiq123'
  # end
end

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }
end
