# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/data', type: :request do
  path '/api/v1/data' do
    get('List crawled data') do
      tags 'Crawled Data'
      description 'Get list of all crawled data'
      produces 'application/json'
      security [bearerAuth: []]

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Items per page'
      parameter name: :crawling_job_id, in: :query, type: :integer, required: false, description: 'Filter by crawling job'
      parameter name: :search, in: :query, type: :string, required: false, description: 'Search in content'
      parameter name: :date_from, in: :query, type: :string, format: :date, required: false, description: 'Filter from date'
      parameter name: :date_to, in: :query, type: :string, format: :date, required: false, description: 'Filter to date'

      response(200, 'successful') do
        let(:Authorization) { 'Bearer valid_token' }

        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer, example: 1 },
                       url: { type: :string, example: 'https://example.com/article-1' },
                       title: { type: :string, example: 'Sample Article Title' },
                       content: { type: :string, example: 'Article content here...' },
                       metadata: {
                         type: :object,
                         properties: {
                           author: { type: :string, example: 'John Doe' },
                           publish_date: { type: :string, format: 'date-time' },
                           tags: {
                             type: :array,
                             items: { type: :string }
                           }
                         }
                       },
                       crawling_job_id: { type: :integer, example: 1 },
                       crawled_at: { type: :string, format: 'date-time' },
                       created_at: { type: :string, format: 'date-time' },
                       updated_at: { type: :string, format: 'date-time' }
                     }
                   }
                 },
                 pagination: {
                   type: :object,
                   properties: {
                     current_page: { type: :integer },
                     total_pages: { type: :integer },
                     total_count: { type: :integer },
                     per_page: { type: :integer }
                   }
                 }
               }

        run_test!
      end

      response(401, 'unauthorized') do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }

        run_test!
      end
    end
  end

  path '/api/v1/data/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true

    get('Show crawled data') do
      tags 'Crawled Data'
      description 'Get details of specific crawled data'
      produces 'application/json'
      security [bearerAuth: []]

      response(200, 'successful') do
        let(:Authorization) { 'Bearer valid_token' }
        let(:id) { 1 }

        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     url: { type: :string },
                     title: { type: :string },
                     content: { type: :string },
                     metadata: {
                       type: :object,
                       additionalProperties: true
                     },
                     crawling_job: {
                       type: :object,
                       properties: {
                         id: { type: :integer },
                         name: { type: :string },
                         url: { type: :string }
                       }
                     },
                     crawled_at: { type: :string, format: 'date-time' },
                     created_at: { type: :string, format: 'date-time' },
                     updated_at: { type: :string, format: 'date-time' }
                   }
                 }
               }

        run_test!
      end

      response(404, 'not found') do
        let(:Authorization) { 'Bearer valid_token' }
        let(:id) { 999 }

        schema type: :object,
               properties: {
                 error: { type: :string }
               }

        run_test!
      end
    end

    delete('Delete crawled data') do
      tags 'Crawled Data'
      description 'Delete specific crawled data entry'
      produces 'application/json'
      security [bearerAuth: []]

      response(204, 'no content') do
        let(:Authorization) { 'Bearer valid_token' }
        let(:id) { 1 }

        run_test!
      end

      response(404, 'not found') do
        let(:Authorization) { 'Bearer valid_token' }
        let(:id) { 999 }

        schema type: :object,
               properties: {
                 error: { type: :string }
               }

        run_test!
      end
    end
  end
end
