# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate_user!, except: [:health_check]
  
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from StandardError, with: :internal_server_error

  def health_check
    render json: {
      status: 'ok',
      timestamp: Time.current,
      version: '1.0.0'
    }
  end

  private

  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    
    if token.blank?
      render json: { error: 'Token missing' }, status: :unauthorized
      return
    end

    begin
      decoded_token = JsonWebToken.decode(token)
      @current_user = User.find(decoded_token[:user_id])
    rescue JWT::DecodeError, JWT::ExpiredSignature
      render json: { error: 'Invalid or expired token' }, status: :unauthorized
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'User not found' }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end

  def record_not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end

  def record_invalid(exception)
    render json: { error: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  def internal_server_error(exception)
    Rails.logger.error "Internal Server Error: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")
    
    render json: { error: 'Internal server error' }, status: :internal_server_error
  end

  def pagination_params
    {
      page: params[:page] || 1,
      per_page: [params[:per_page]&.to_i || 20, 100].min
    }
  end
end
