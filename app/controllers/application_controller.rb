class ApplicationController < ActionController::API
  include ActionController::Cookies
  # middleware.use ActionDispatch::Cookies
  before_action :authenticate_request

  private

  def authenticate_request
    token = cookies.signed[:auth]
    raise Exceptions::Unauthorized unless token.present?

    begin
      decoded = JWT.decode(token, Rails.application.credentials.jwt_secret, true, { algorithm: "HS256" })
      @current_user = User.find_by(id: decoded.first["user_id"])
      raise Exceptions::Unauthorized('invalid user') unless decoded.present? && @current_user.present?

    rescue JWT::DecodeError => e
      Rails.logger.error "JWT Decode Error: #{e.message}"
      raise Exceptions::Unauthorized('invalid token')
    rescue JWT::ExpiredSignature
      raise Exceptions::Unauthorized('expired token')
    end
  end

  def is_verified_user(user_id)
    User.find_by(id: user_id).present?
  end
end
