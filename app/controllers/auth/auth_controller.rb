module Auth
  class AuthController < ApplicationController
    skip_before_action :authenticate_request, only: [:create_auth_token]
    def create_auth_token
      user = User.by_email(email_param)
      if user&.authenticate(password_param)
        token = encode_token({ user_id: user.id })
        set_jwt_cookie(token)

        @current_user = user
      else
        render json: { error: 'Invalid email or password' }, status: :unauthorized
      end
    end

    def destroy_auth
      cookies.delete(:auth)
      render json: { message: 'Logged out' }, status: :ok
    end

    private

    def email_param
      params.require(:email)
    end

    def password_param
      params.require(:password)
    end

    def encode_token(payload)
      JWT.encode(payload, Rails.application.credentials.jwt_secret, "HS256")
    end

    def set_jwt_cookie(token)
      cookies.signed[:auth] = {
        value: token,
        httponly: true,
        secure: Rails.env.production?,
        same_site: :none
      }
    end
  end
end
