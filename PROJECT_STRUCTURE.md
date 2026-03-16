# 📚 DC-BE Project Structure Documentation

## 🎯 Tổng quan dự án

**DC-BE** là một Rails API application được containerized với Docker, sử dụng kiến trúc microservices cho backend của một hệ thống web hiện đại.

### 🏗️ Tech Stack
- **Backend Framework**: Ruby on Rails 7.0 (API-only mode)
- **Database**: PostgreSQL 15
- **Caching & Job Queue**: Redis 7
- **Background Jobs**: Sidekiq
- **Containerization**: Docker & Docker Compose
- **Authentication**: JWT + BCrypt

---

## 📁 Cấu trúc thư mục chính

```
dc-be/
├── 🐳 Docker Configuration
│   ├── docker-compose.yml      # Service orchestration
│   └── Dockerfile             # Container build instructions
│
├── 🚀 Rails Application
│   ├── Gemfile                # Ruby dependencies
│   ├── Gemfile.lock          # Locked dependency versions
│   ├── config/               # Rails configuration
│   ├── app/                  # Application code
│   ├── db/                   # Database migrations & seeds
│   └── bin/                  # Executable scripts
│
├── 📝 Documentation & Config
│   ├── README.md             # Project documentation
│   ├── .env.example         # Environment variables template
│   └── .gitignore           # Git ignore rules
│
└── 📊 Development Files
    ├── log/                  # Application logs
    ├── tmp/                  # Temporary files
    └── spec/                 # Test specifications
```

---

## 🐳 Docker Infrastructure

### `docker-compose.yml` - Service Orchestration

File này định nghĩa 4 services chính:

#### 1. 🗄️ **Database Service (db)**
```yaml
db:
  image: postgres:15
  environment:
    POSTGRES_DB: dc_be_development
    POSTGRES_USER: postgres
    POSTGRES_PASSWORD: password
  ports:
    - "5432:5432"
  volumes:
    - postgres_data:/var/lib/postgresql/data
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U postgres"]
    interval: 30s
    timeout: 10s
    retries: 5
```

**Vai trò:**
- ✅ Primary data storage cho application
- ✅ ACID transactions đảm bảo data integrity
- ✅ Relational data modeling
- ✅ Health check tự động kiểm tra trạng thái

**Ports:** `5432:5432` - Expose PostgreSQL port cho external connections

#### 2. 📦 **Redis Service (redis)**
```yaml
redis:
  image: redis:7-alpine
  ports:
    - "6379:6379"
  volumes:
    - redis_data:/data
```

**Vai trò:**
- ✅ Application caching layer
- ✅ Session storage
- ✅ Sidekiq job queue backend
- ✅ Real-time data storage

**Ports:** `6379:6379` - Standard Redis port

#### 3. 🌐 **Web Service (web)**
```yaml
web:
  build: .
  ports:
    - "3001:3000"
  depends_on:
    db:
      condition: service_healthy
    redis:
      condition: service_started
  environment:
    DATABASE_URL: postgresql://postgres:password@db:5432/dc_be_development
    REDIS_URL: redis://redis:6379/0
    JWT_SECRET: your_super_secret_jwt_key
    RAILS_ENV: development
  volumes:
    - .:/app
  command: >
    bash -c "
      bundle exec rails db:create db:migrate db:seed 2>/dev/null || true &&
      bundle exec rails server -b 0.0.0.0
    "
```

**Vai trò:**
- ✅ Main Rails API server
- ✅ Handle HTTP requests/responses
- ✅ Authentication & authorization
- ✅ Business logic execution

**Ports:** `3001:3000` - Map container port 3000 to host port 3001

**Dependencies:**
- Chờ `db` service healthy trước khi start
- Chờ `redis` service started

**Startup Process:**
1. Tạo database nếu chưa có
2. Chạy migrations
3. Seed initial data
4. Start Rails server trên tất cả interfaces (0.0.0.0)

#### 4. ⚙️ **Sidekiq Service (sidekiq)**
```yaml
sidekiq:
  build: .
  depends_on:
    db:
      condition: service_healthy  
    redis:
      condition: service_started
    web:
      condition: service_started
  environment:
    DATABASE_URL: postgresql://postgres:password@db:5432/dc_be_development
    REDIS_URL: redis://redis:6379/0
    RAILS_ENV: development
  volumes:
    - .:/app
  command: bundle exec sidekiq
```

**Vai trò:**
- ✅ Background job processing
- ✅ Async task execution
- ✅ Email sending
- ✅ Data processing tasks

**Dependencies:**
- Chờ `db`, `redis`, và `web` services sẵn sàng

### `Dockerfile` - Container Build

```dockerfile
# Base Image: Ruby 3.2.0-slim
FROM ruby:3.2.0-slim

# System Dependencies
RUN apt-get update -qq && \
    apt-get install -y \
    build-essential \    # Compile native extensions
    libpq-dev \         # PostgreSQL client library
    nodejs \            # JavaScript runtime
    git \               # Version control
    && rm -rf /var/lib/apt/lists/*

# Working Directory
WORKDIR /app

# Install Ruby Gems
COPY Gemfile* ./
RUN bundle lock --add-platform ruby --add-platform x86_64-linux --add-platform aarch64-linux
RUN bundle config set --local force_ruby_platform true
RUN bundle install --jobs 4 --retry 3

# Copy Application Code
COPY . .

# Security: Non-root User
RUN groupadd -r appuser && useradd -r -g appuser appuser
RUN chown -R appuser:appuser /app
USER appuser
```

**Các tính năng quan trọng:**
- ✅ **Multi-platform support**: Hỗ trợ x86_64 và ARM64
- ✅ **Security hardening**: Chạy với non-root user
- ✅ **Optimized builds**: Multi-core gem installation
- ✅ **Minimal attack surface**: Slim base image

---

## 🚀 Rails Application Structure

### `Gemfile` - Dependencies Management

```ruby
source 'https://rubygems.org'
ruby '3.2.0'

# Core Rails
gem 'rails', '~> 7.0.0'
gem 'pg', '~> 1.1'              # PostgreSQL adapter
gem 'puma', '~> 5.0'            # Web server

# API Features
gem 'rack-cors'                 # Cross-Origin Resource Sharing
gem 'jbuilder'                  # JSON response builder

# Authentication
gem 'jwt'                       # JSON Web Tokens
gem 'bcrypt', '~> 3.1.7'       # Password hashing

# Background Jobs
gem 'sidekiq'                   # Job processing
gem 'redis'                     # Redis client

# Development & Test
group :development, :test do
  gem 'rspec-rails'             # Testing framework
  gem 'factory_bot_rails'       # Test data factories
  gem 'faker'                   # Fake data generation
end
```

### `config/application.rb` - Rails Configuration

```ruby
module DcBe
  class Application < Rails::Application
    config.load_defaults 7.0

    # API-only application
    config.api_only = true

    # CORS configuration
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*' # Configure for production
        resource '*',
          headers: :any,
          methods: [:get, :post, :put, :patch, :delete, :options, :head]
      end
    end

    # Timezone
    config.time_zone = 'Asia/Ho_Chi_Minh'

    # Background jobs
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
```

### `app/` Directory Structure

```
app/
├── controllers/          # API Endpoints
│   ├── application_controller.rb
│   ├── api/
│   │   └── v1/
│   │       ├── users_controller.rb
│   │       ├── auth_controller.rb
│   │       └── ...
│   
├── models/              # Data Models
│   ├── application_record.rb
│   ├── user.rb
│   └── ...
│
├── services/            # Business Logic
│   ├── auth_service.rb
│   ├── user_service.rb
│   └── ...
│
├── serializers/         # JSON Response Formatting
│   ├── user_serializer.rb
│   └── ...
│
└── jobs/               # Background Jobs
    ├── application_job.rb
    ├── email_job.rb
    └── ...
```

---

## 🔄 Data Flow & Architecture

### 1. **Request Flow**
```
Client Request
    ↓
Docker Network (dc-be_default)
    ↓
Web Container (Port 3001)
    ↓
Rails Router
    ↓
Controller (API::V1::UsersController)
    ↓
Service Layer (UserService)
    ↓
Model Layer (User)
    ↓
PostgreSQL Database
    ↓
Serializer (UserSerializer)
    ↓
JSON Response
```

### 2. **Background Job Flow**
```
Web Request
    ↓
Controller enqueues job
    ↓
Redis Queue
    ↓
Sidekiq Worker
    ↓
Job Execution
    ↓
Database/External API
```

### 3. **Container Network**
```
dc-be_default Network
├── db:5432        (PostgreSQL)
├── redis:6379     (Redis)
├── web:3000       (Rails API)
└── sidekiq        (Background Jobs)
```

---

## 🛡️ Security Features

### Container Security
- ✅ **Non-root execution**: Containers chạy với user `appuser`
- ✅ **Minimal base images**: Giảm attack surface
- ✅ **No unnecessary packages**: Chỉ install dependencies cần thiết
- ✅ **Environment variables**: Sensitive data không hardcode

### Application Security
- ✅ **JWT Authentication**: Stateless authentication
- ✅ **BCrypt Password Hashing**: Secure password storage
- ✅ **CORS Configuration**: Control cross-origin requests
- ✅ **API-only mode**: No view layer vulnerabilities
- ✅ **Input validation**: Strong parameter filtering

---

## 🚀 Development Workflow

### 1. **Start Services**
```bash
docker-compose up -d
```

### 2. **Check Status**
```bash
docker-compose ps
```

### 3. **View Logs**
```bash
docker-compose logs -f web sidekiq
```

### 4. **Execute Commands**
```bash
# Rails console
docker-compose exec web rails console

# Database migrations
docker-compose exec web rails db:migrate

# Run tests
docker-compose exec web rspec
```

### 5. **Stop Services**
```bash
docker-compose down
```

---

## 🎛️ **Web Interfaces & Monitoring**

### **Sidekiq Web UI** (Available!)
```
http://localhost:3001/sidekiq
```

**Features:**
- 📊 Monitor background jobs in real-time
- 📈 View job statistics and queues
- 🔍 Debug failed jobs with stack traces
- ⚡ Real-time job processing status
- 🗂️ Browse scheduled, retry, and dead job sets

**Security:** Protected by Rails session middleware for CSRF protection

### **Health Check Endpoint**
```
GET http://localhost:3001/health
```

### **API Documentation**
Currently available endpoints:
```bash
# Authentication
POST /api/v1/auth/login
POST /api/v1/auth/register  
DELETE /api/v1/auth/logout
GET /api/v1/auth/profile

# Crawling Jobs
GET /api/v1/crawling_jobs
POST /api/v1/crawling_jobs
POST /api/v1/crawling_jobs/:id/start

# Data Management  
GET /api/v1/data
GET /api/v1/data/:id
DELETE /api/v1/data/:id
```

---

## 📊 Monitoring & Health Checks

### Database Health Check
```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U postgres"]
  interval: 30s
  timeout: 10s
  retries: 5
```

### Service Dependencies
- **Web**: Chờ DB healthy, Redis started
- **Sidekiq**: Chờ DB healthy, Redis started, Web started

### Log Monitoring
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f web
```

---

## 🔧 Configuration Management

### Environment Variables
```bash
# Database
DATABASE_URL=postgresql://postgres:password@db:5432/dc_be_development

# Redis
REDIS_URL=redis://redis:6379/0

# Authentication
JWT_SECRET=your_super_secret_jwt_key

# Rails
RAILS_ENV=development
```

### Volume Mounts
- **postgres_data**: PostgreSQL data persistence
- **redis_data**: Redis data persistence
- **.:/app**: Source code hot reload (development)

---

## 🎯 Production Considerations

### Environment Separation
```yaml
# development
RAILS_ENV: development

# production
RAILS_ENV: production
DATABASE_URL: ${DATABASE_URL}
REDIS_URL: ${REDIS_URL}
JWT_SECRET: ${JWT_SECRET}
```

### Security Enhancements
- ✅ Use secrets management (Docker secrets, Kubernetes secrets)
- ✅ Configure proper CORS origins
- ✅ Enable SSL/TLS
- ✅ Implement rate limiting
- ✅ Add monitoring and logging

### Scaling Options
- ✅ Multiple web instances behind load balancer
- ✅ Redis cluster for high availability
- ✅ PostgreSQL read replicas
- ✅ Horizontal Sidekiq scaling

---

## 📝 Summary

Dự án **DC-BE** là một Rails API application hiện đại với:

✅ **Containerized Architecture**: Dễ dàng deploy và scale  
✅ **Microservices Pattern**: Tách biệt concerns rõ ràng  
✅ **Production-Ready**: Security, health checks, monitoring  
✅ **Developer-Friendly**: Hot reload, easy debugging  
✅ **Scalable Design**: Horizontal scaling capabilities  

Project này phù hợp làm backend cho web applications, mobile apps, hoặc microservices ecosystem! 🚀

---

*Generated on: March 16, 2026*
*Author: Development Team*
