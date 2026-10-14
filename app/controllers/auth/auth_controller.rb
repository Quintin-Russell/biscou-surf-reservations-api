module Auth
  class AuthController < ApplicationController
    allow_unauthorized_access only: %i[ login email_exists destroy_auth ]
    rate_limit to: 10, within: 10.minutes, name: "email-check", only: :email_exists,
      with: -> { render json: { error: "Too many attempts" }, status: :too_many_requests }
    rate_limit to: 10, within: 1.minutes, name: "login-attempt", only: :login,
      with: -> { render json: { error: "Too many attempts" }, status: :too_many_requests }

    def email_exists
      @email_exists = User.by_email(email_param)
    end

    def show_current_user
      @current_user = Current.user
    end

    def login
      user = User.by_email(email_param)
      if user&.authenticate(password_param)
        start_new_session(user)
        @current_user = user
      else
        render json: { error: 'Invalid email or password' }, status: :unauthorized
      end
    end

    def destroy_auth
      has_session
      end_session
      head :no_content
    end

    private

    def email_param
      params.require(:email)
    end

    def password_param
      params.require(:password)
    end
  end
end
