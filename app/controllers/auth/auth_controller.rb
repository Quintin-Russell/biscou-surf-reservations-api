class ApplicationController < ActionController::API
  def create_auth_token
    user = User.by_email(auth_params[:email])
    if user&.authenticate(auth_params[:password])
      token = JsonWebToken.encode(user_id: user.id)

      cookies.signed[:jwt] = {
        value: token,
        httponly: true,
        secure: Rails.env.production?,
        same_site: :strict
      }

      render json: { message: 'Logged in successfully' }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  def destroy_auth
    cookies.delete(:jwt)
    render json: { message: 'Logged out' }, status: :ok
  end

  private

  def auth_params
    params.require(:email, :password)
  end
end