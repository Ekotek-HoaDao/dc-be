require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DcBe
  class Application < Rails::Application
    # Configuration for the application, engines, and railties goes here.
    config.load_defaults 7.0

    # API-only application
    config.api_only = true

    # CORS configuration
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*' # Configure this properly for production
        resource '*',
          headers: :any,
          methods: [:get, :post, :put, :patch, :delete, :options, :head]
      end
    end

    # Time zone
    config.time_zone = 'Asia/Ho_Chi_Minh'

    # Active Job adapter
    config.active_job.queue_adapter = :sidekiq

    # Autoload paths
    config.autoload_paths += %W[
      #{Rails.root}/app/services
      #{Rails.root}/app/serializers
      #{Rails.root}/app/jobs
    ]

    # Generator configuration
    config.generators do |g|
      g.orm :active_record
      g.test_framework :rspec
      g.factory_bot_suffix 'factory'
      g.skip_routes true
    end

    # Enable session middleware for Sidekiq::Web in development
    if Rails.env.development?
      config.session_store :cookie_store, key: '_dc_be_session'
      config.middleware.use ActionDispatch::Cookies
      config.middleware.use config.session_store, config.session_options
    end
  end
end
