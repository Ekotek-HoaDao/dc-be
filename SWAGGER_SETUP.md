# 📝 Hướng dẫn thêm Swagger vào DC-BE Project

## 🎯 Thêm Swagger Documentation

### 1. Thêm gem vào Gemfile:
```ruby
# API Documentation
gem 'rswag'

group :development, :test do
  gem 'rswag-specs'
end

group :development do
  gem 'rswag-ui'
  gem 'rswag-api'
end
```

### 2. Chạy bundle install:
```bash
docker-compose exec web bundle install
```

### 3. Generate Swagger config:
```bash
docker-compose exec web rails generate rswag:install
```

### 4. Thêm routes cho Swagger:
```ruby
# config/routes.rb
Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  
  # ...existing routes
end
```

### 5. Tạo API spec files:
```ruby
# spec/requests/api/v1/auth_spec.rb
require 'swagger_helper'

RSpec.describe 'Authentication API', type: :request do
  path '/api/v1/auth/login' do
    post 'User login' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string }
        },
        required: ['email', 'password']
      }
      
      response '200', 'successful login' do
        schema type: :object,
               properties: {
                 token: { type: :string },
                 user: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     email: { type: :string }
                   }
                 }
               }
        run_test!
      end
      
      response '401', 'unauthorized' do
        run_test!
      end
    end
  end
end
```

### 6. Generate Swagger JSON:
```bash
docker-compose exec web rails rswag
```

### 7. Truy cập Swagger UI:
```
http://localhost:3001/api-docs
```

## 🔍 Current Available Endpoints:

### Sidekiq Web UI (Đã có sẵn):
```
http://localhost:3001/sidekiq
```

### Health Check:
```
GET http://localhost:3001/health
```

### API Endpoints:
```
# Auth
POST /api/v1/auth/login
POST /api/v1/auth/register
DELETE /api/v1/auth/logout
GET /api/v1/auth/profile

# Crawling
GET /api/v1/crawling_jobs
POST /api/v1/crawling_jobs
POST /api/v1/crawling_jobs/:id/start

# Data
GET /api/v1/data
GET /api/v1/data/:id
```
