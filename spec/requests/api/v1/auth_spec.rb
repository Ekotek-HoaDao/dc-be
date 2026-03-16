# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/auth', type: :request do
  path '/api/v1/auth/login' do
    post('Login') do
      tags 'Authentication'
      description 'Authenticate user and get JWT token'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: {
            type: :string,
            format: :email,
            example: 'admin@dcbe.com'
          },
          password: {
            type: :string,
            example: 'password123'
          }
        },
        required: ['email', 'password']
      }

      response(200, 'successful') do
        let(:credentials) { { email: 'admin@dcbe.com', password: 'password123' } }

        schema type: :object,
               properties: {
                 token: {
                   type: :string,
                   example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
                 },
                 user: {
                   type: :object,
                   properties: {
                     id: { type: :integer, example: 1 },
                     email: { type: :string, example: 'admin@dcbe.com' },
                     created_at: { type: :string, format: 'date-time' },
                     updated_at: { type: :string, format: 'date-time' }
                   }
                 }
               },
               required: ['token', 'user']

        run_test!
      end

      response(401, 'unauthorized') do
        let(:credentials) { { email: 'invalid@email.com', password: 'wrong' } }

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Invalid credentials' }
               }

        run_test!
      end

      response(422, 'unprocessable entity') do
        let(:credentials) { { email: 'invalid-email' } }

        schema type: :object,
               properties: {
                 errors: {
                   type: :object,
                   properties: {
                     email: { type: :array, items: { type: :string } },
                     password: { type: :array, items: { type: :string } }
                   }
                 }
               }

        run_test!
      end
    end
  end

  path '/api/v1/auth/register' do
    post('Register') do
      tags 'Authentication'
      description 'Register new user account'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user_params, in: :body, schema: {
        type: :object,
        properties: {
          email: {
            type: :string,
            format: :email,
            example: 'newuser@dcbe.com'
          },
          password: {
            type: :string,
            minLength: 6,
            example: 'password123'
          },
          password_confirmation: {
            type: :string,
            example: 'password123'
          }
        },
        required: ['email', 'password', 'password_confirmation']
      }

      response(201, 'created') do
        let(:user_params) do
          {
            email: 'newuser@dcbe.com',
            password: 'password123',
            password_confirmation: 'password123'
          }
        end

        schema type: :object,
               properties: {
                 token: { type: :string },
                 user: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     email: { type: :string },
                     created_at: { type: :string, format: 'date-time' },
                     updated_at: { type: :string, format: 'date-time' }
                   }
                 }
               }

        run_test!
      end

      response(422, 'unprocessable entity') do
        let(:user_params) { { email: 'invalid' } }

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

  path '/api/v1/auth/profile' do
    get('Get user profile') do
      tags 'Authentication'
      description 'Get current user profile information'
      produces 'application/json'
      security [bearerAuth: []]

      response(200, 'successful') do
        let(:Authorization) { 'Bearer valid_token' }

        schema type: :object,
               properties: {
                 user: {
                   type: :object,
                   properties: {
                     id: { type: :integer, example: 1 },
                     email: { type: :string, example: 'admin@dcbe.com' },
                     created_at: { type: :string, format: 'date-time' },
                     updated_at: { type: :string, format: 'date-time' }
                   }
                 }
               }

        run_test!
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid_token' }

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Token missing' }
               }

        run_test!
      end
    end
  end

  path '/api/v1/auth/logout' do
    delete('Logout') do
      tags 'Authentication'
      description 'Logout user and invalidate token'
      produces 'application/json'
      security [bearerAuth: []]

      response(200, 'successful') do
        let(:Authorization) { 'Bearer valid_token' }

        schema type: :object,
               properties: {
                 message: { type: :string, example: 'Logged out successfully' }
               }

        run_test!
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid_token' }

        schema type: :object,
               properties: {
                 error: { type: :string }
               }

        run_test!
      end
    end
  end
end
