Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # Health check
  get '/health', to: 'application#health_check'
  
  # API routes
  namespace :api do
    namespace :v1 do
      # Authentication
      namespace :auth do
        post 'login', to: 'login#create'
        post 'register', to: 'register#create'
        delete 'logout', to: 'logout#destroy'
        get 'profile', to: 'profile#show'
      end

      # Crawling Jobs
      resources :crawling_jobs do
        member do
          post 'start'
          post 'pause'
          post 'resume'
          post 'stop'
        end
      end

      # Crawled Data
      resources :data, only: [:index, :show, :destroy]
    end
  end

  # Sidekiq Web UI (for development)
  if Rails.env.development?
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end
end
