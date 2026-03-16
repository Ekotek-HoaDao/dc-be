# frozen_string_literal: true

module Api
  module V1
    module Auth
      class LoginController < BaseController
        skip_before_action :authenticate_user!, only: [:create]

        def create
          user = User.find_by(email: login_params[:email])

          if user&.authenticate(login_params[:password])
            token = JsonWebToken.encode(user_id: user.id)
            render_success({
              user: UserSerializer.new(user).as_json,
              token: token
            }, 'Login successful')
          else
            render_error('Invalid email or password', :unauthorized)
          end
        end

        private

        def login_params
          params.require(:user).permit(:email, :password)
        end
      end
    end
  end
end
