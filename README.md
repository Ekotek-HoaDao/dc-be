# DC-BE - Data Crawling Backend API

Ruby on Rails API application cho việc crawling data và cung cấp API endpoints.

## Features

- **API Endpoints**: RESTful API cho các operations cơ bản
- **Crawling Module**: Module crawling data từ các nguồn khác nhau
- **Background Jobs**: Xử lý crawling data trong background với Sidekiq
- **Authentication**: JWT-based authentication
- **Caching**: Redis caching cho performance
- **Database**: PostgreSQL database

## Setup

### Prerequisites

- Ruby 3.2.0
- PostgreSQL
- Redis

### Installation

1. Clone repository:
```bash
git clone <repo-url>
cd dc-be
```

2. Install dependencies:
```bash
bundle install
```

3. Setup environment variables:
```bash
cp .env.example .env
```

4. Setup database:
```bash
rails db:create
rails db:migrate
rails db:seed
```

5. Start services:
```bash
# Start Redis (for Sidekiq)
redis-server

# Start Sidekiq (in another terminal)
bundle exec sidekiq

# Start Rails server
rails server
```

## API Endpoints

### Authentication
- `POST /api/v1/auth/login` - Login
- `POST /api/v1/auth/register` - Register
- `DELETE /api/v1/auth/logout` - Logout

### Crawling Jobs
- `GET /api/v1/crawling_jobs` - List crawling jobs
- `POST /api/v1/crawling_jobs` - Create crawling job
- `GET /api/v1/crawling_jobs/:id` - Get crawling job
- `PUT /api/v1/crawling_jobs/:id` - Update crawling job
- `DELETE /api/v1/crawling_jobs/:id` - Delete crawling job

### Data
- `GET /api/v1/data` - List crawled data
- `GET /api/v1/data/:id` - Get specific data

## Crawling Module

Module crawling hỗ trợ:
- HTTP requests với retry mechanism
- HTML/XML parsing với Nokogiri
- Configurable crawling rules
- Rate limiting
- Data validation và cleaning

## Architecture

```
app/
├── controllers/
│   └── api/
│       └── v1/
├── models/
├── services/
│   └── crawling/
├── jobs/
└── serializers/
```

## Environment Variables

```env
# Database
DATABASE_URL=postgresql://username:password@localhost/dc_be_development

# Redis
REDIS_URL=redis://localhost:6379/0

# JWT
JWT_SECRET=your_jwt_secret

# Crawling
MAX_CONCURRENT_REQUESTS=5
REQUEST_DELAY=1000
```
