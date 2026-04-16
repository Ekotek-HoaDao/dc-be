# frozen_string_literal: true

# SimpleCov configuration - phải đặt ở đầu file
require 'simplecov'
require 'simplecov-cobertura'

SimpleCov.start 'rails' do
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/vendor/'
  add_filter '/app/channels/' # if not using ActionCable
  
  # Coverage output formats
  SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::CoberturaFormatter
  ])
  
  coverage_dir 'coverage'
  
  # Set minimum coverage
  minimum_coverage 70
end

# Configure Rails Environment
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
