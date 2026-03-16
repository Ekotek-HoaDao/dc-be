# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Health Check', type: :request do
  path '/health' do
    get('Health check') do
      tags 'System'
      description 'Check API health status'
      produces 'application/json'

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 status: { type: :string, example: 'ok' },
                 timestamp: { type: :string, format: 'date-time' },
                 version: { type: :string, example: '1.0.0' }
               },
               required: ['status', 'timestamp', 'version']

        run_test!
      end
    end
  end
end
