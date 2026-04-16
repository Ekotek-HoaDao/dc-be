# frozen_string_literal: true

module Api
  module V1
    module Auth
      class RegisterController < BaseController
        skip_before_action :authenticate_user!, only: [:create]

        def create
          user = User.new(register_params)

          if user.save
            token = JsonWebToken.encode(user_id: user.id)
            render_success({
              user: UserSerializer.new(user).as_json,
              token: token
            }, 'Registration successful', :created)
          else
            render_error('Registration failed', :unprocessable_entity, user.errors.full_messages)
          end
        end

        private

        def register_params
          # Accept both user nested params and direct params
          if params[:user].present?
            params.require(:user).permit(:email, :password, :password_confirmation, :name)
          else
            params.permit(:email, :password, :password_confirmation, :name)
          end
        end
      end
    end
  end
end
