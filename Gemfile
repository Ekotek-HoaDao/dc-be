# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.0'

# Core Rails gems
gem 'rails', '~> 7.0.0'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'

# API specific gems
gem 'rack-cors'
gem 'jbuilder'

# Authentication & Authorization
gem 'jwt'
gem 'bcrypt', '~> 3.1.7'

# Background Jobs
gem 'sidekiq'
gem 'redis'

# HTTP Client for crawling
gem 'httparty'
gem 'faraday'
gem 'faraday-retry'

# HTML/XML parsing
gem 'nokogiri'

# Data processing
gem 'oj' # Fast JSON parser
gem 'kaminari' # Pagination

# Configuration
gem 'dotenv-rails'

# Caching
gem 'bootsnap', '>= 1.4.4', require: false

# API Documentation
gem 'rswag'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rswag-specs'
end

group :development do
  gem 'listen', '~> 3.3'
  gem 'spring'
  gem 'annotate'
  gem 'rswag-ui'
  gem 'rswag-api'
end

group :test do
  gem 'webmock'
  gem 'vcr'
  gem 'simplecov', require: false
  gem 'simplecov-cobertura'
  gem 'rspec_junit_formatter'
end
