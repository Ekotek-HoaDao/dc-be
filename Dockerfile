# Use Ruby 3.2.0
FROM ruby:3.2.0-slim

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy Gemfile and install gems
COPY Gemfile* ./

# Add required platforms to bundle and install gems
RUN bundle lock --add-platform ruby --add-platform x86_64-linux --add-platform aarch64-linux
RUN bundle config set --local force_ruby_platform true
RUN bundle install --jobs 4 --retry 3

# Copy application code
COPY . .

# Create a non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser
RUN chown -R appuser:appuser /app
USER appuser

# Expose port
EXPOSE 3000

# Default command
CMD ["rails", "server", "-b", "0.0.0.0"]
