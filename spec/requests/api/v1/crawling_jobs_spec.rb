# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/crawling_jobs', type: :request do
  path '/api/v1/crawling_jobs' do
    get('List crawling jobs') do
      tags 'Crawling Jobs'
      description 'Get list of all crawling jobs'
      produces 'application/json'
      security [bearerAuth: []]

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Items per page'
      parameter name: :status, in: :query, type: :string, required: false, enum: %w[pending running paused completed failed], description: 'Filter by status'

      response(200, 'successful') do
        let(:Authorization) { 'Bearer valid_token' }

        schema type: :object,
               properties: {
                 crawling_jobs: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer, example: 1 },
                       name: { type: :string, example: 'News Crawl Job' },
                       url: { type: :string, example: 'https://example.com' },
                       status: { type: :string, enum: %w[pending running paused completed failed] },
                       schedule: { type: :string, example: '0 */6 * * *' },
                       last_run_at: { type: :string, format: 'date-time', nullable: true },
                       next_run_at: { type: :string, format: 'date-time', nullable: true },
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

    post('Create crawling job') do
      tags 'Crawling Jobs'
      description 'Create a new crawling job'
      consumes 'application/json'
      produces 'application/json'
      security [bearerAuth: []]

      parameter name: :crawling_job, in: :body, schema: {
        type: :object,
        properties: {
          name: {
            type: :string,
            example: 'Daily News Crawl'
          },
          url: {
            type: :string,
            format: :uri,
            example: 'https://news.example.com'
          },
          schedule: {
            type: :string,
            example: '0 9 * * *',
            description: 'Cron expression'
          },
          selector: {
            type: :string,
            example: '.article',
            description: 'CSS selector for content'
          },
          description: {
            type: :string,
            example: 'Crawl daily news articles'
          }
        },
        required: ['name', 'url']
      }

      response(201, 'created') do
        let(:Authorization) { 'Bearer valid_token' }
        let(:crawling_job) do
          {
            name: 'Test Crawl',
            url: 'https://example.com',
            schedule: '0 9 * * *'
          }
        end

        schema type: :object,
               properties: {
                 crawling_job: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     name: { type: :string },
                     url: { type: :string },
                     status: { type: :string },
                     schedule: { type: :string },
                     selector: { type: :string },
                     description: { type: :string },
                     created_at: { type: :string, format: 'date-time' },
                     updated_at: { type: :string, format: 'date-time' }
                   }
                 }
               }

        run_test!
      end

      response(422, 'unprocessable entity') do
        let(:Authorization) { 'Bearer valid_token' }
        let(:crawling_job) { { name: '' } }

        schema type: :object,
               properties: {
                 errors: {
                   type: :object,
                   additionalProperties: {
                     type: :array,
                     items: { type: :string }
                   }
                 }
               }

        run_test!
      end
    end
  end

  path '/api/v1/crawling_jobs/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true

    get('Show crawling job') do
      tags 'Crawling Jobs'
      description 'Get details of a specific crawling job'
      produces 'application/json'
      security [bearerAuth: []]

      response(200, 'successful') do
        let(:Authorization) { 'Bearer valid_token' }
        let(:id) { 1 }

        schema type: :object,
               properties: {
                 crawling_job: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     name: { type: :string },
                     url: { type: :string },
                     status: { type: :string },
                     schedule: { type: :string },
                     selector: { type: :string },
                     description: { type: :string },
                     last_run_at: { type: :string, format: 'date-time', nullable: true },
                     next_run_at: { type: :string, format: 'date-time', nullable: true },
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

    put('Update crawling job') do
      tags 'Crawling Jobs'
      description 'Update an existing crawling job'
      consumes 'application/json'
      produces 'application/json'
      security [bearerAuth: []]

      parameter name: :crawling_job, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          url: { type: :string, format: :uri },
          schedule: { type: :string },
          selector: { type: :string },
          description: { type: :string }
        }
      }

      response(200, 'successful') do
        let(:Authorization) { 'Bearer valid_token' }
        let(:id) { 1 }
        let(:crawling_job) { { name: 'Updated Job Name' } }

        schema type: :object,
               properties: {
                 crawling_job: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     name: { type: :string },
                     url: { type: :string },
                     status: { type: :string },
                     schedule: { type: :string },
                     selector: { type: :string },
                     description: { type: :string },
                     created_at: { type: :string, format: 'date-time' },
                     updated_at: { type: :string, format: 'date-time' }
                   }
                 }
               }

        run_test!
      end
    end

    delete('Delete crawling job') do
      tags 'Crawling Jobs'
      description 'Delete a crawling job'
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

        run_test!
      end
    end
  end

  path '/api/v1/crawling_jobs/{id}/start' do
    parameter name: :id, in: :path, type: :integer, required: true

    post('Start crawling job') do
      tags 'Crawling Jobs'
      description 'Start or resume a crawling job'
      produces 'application/json'
      security [bearerAuth: []]

      response(200, 'successful') do
        let(:Authorization) { 'Bearer valid_token' }
        let(:id) { 1 }

        schema type: :object,
               properties: {
                 message: { type: :string, example: 'Job started successfully' },
                 crawling_job: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     status: { type: :string, example: 'running' }
                   }
                 }
               }

        run_test!
      end
    end
  end

  path '/api/v1/crawling_jobs/{id}/pause' do
    parameter name: :id, in: :path, type: :integer, required: true

    post('Pause crawling job') do
      tags 'Crawling Jobs'
      description 'Pause a running crawling job'
      produces 'application/json'
      security [bearerAuth: []]

      response(200, 'successful') do
        let(:Authorization) { 'Bearer valid_token' }
        let(:id) { 1 }

        schema type: :object,
               properties: {
                 message: { type: :string, example: 'Job paused successfully' },
                 crawling_job: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     status: { type: :string, example: 'paused' }
                   }
                 }
               }

        run_test!
      end
    end
  end

  path '/api/v1/crawling_jobs/{id}/stop' do
    parameter name: :id, in: :path, type: :integer, required: true

    post('Stop crawling job') do
      tags 'Crawling Jobs'
      description 'Stop a running crawling job'
      produces 'application/json'
      security [bearerAuth: []]

      response(200, 'successful') do
        let(:Authorization) { 'Bearer valid_token' }
        let(:id) { 1 }

        schema type: :object,
               properties: {
                 message: { type: :string, example: 'Job stopped successfully' },
                 crawling_job: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     status: { type: :string, example: 'stopped' }
                   }
                 }
               }

        run_test!
      end
    end
  end
end
