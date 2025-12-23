class ApplicationController < ActionController::Base
  include ActionController::Cookies
  # middleware.use ActionDispatch::Cookies
  protect_from_forgery with: :null_session
  before_action :authenticate_request

  private

  def authenticate_request
    puts cookies.to_h
    token = cookies.signed[:auth]
    unless token
      render json: { error: 'No authentication token. Authentication required' }, status: :unauthorized
    end

    begin
      decoded = JWT.decode(token, Rails.application.credentials.jwt_secret, true, { algorithm: "HS256" })
      unless decoded && is_verified_user(decoded.first["user_id"])
        render json: { error: 'Invalid user' }, status: :unauthorized
        return
      end
    rescue JWT::DecodeError => e
      Rails.logger.error "JWT Decode Error: #{e.message}"
      render json: { error: 'Invalid token' }, status: :unauthorized
    rescue JWT::ExpiredSignature
      render json: { error: 'Token expired' }, status: :unauthorized
    end
  end

  def is_verified_user(user_id)
    User.find_by(id: user_id).present?
  end
end
