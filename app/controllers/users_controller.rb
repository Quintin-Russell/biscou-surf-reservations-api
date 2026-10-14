class UsersController < ApplicationController
  allow_unauthorized_access only: %i[ create ]

  def create
    @current_user = User.create!(new_user_params)
    start_new_session(@current_user)
  end

  private

  def new_user_params
    permitted_params = params.permit(:first_name, :last_name, :email, :password, :nationality, :phone_number)
    required_params = ["first_name", "last_name", "email", "password", "nationality", "phone_number"]
    missing_params = required_params.reject{ |req_param| permitted_params[req_param].present? }
    raise Exceptions::MissingParameters if missing_params.any?
    permitted_params
  end
end
