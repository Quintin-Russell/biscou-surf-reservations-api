class UsersController < ApplicationController
  skip_before_action :authenticate_request, only: [:create]

  def create
    @current_user = User.create!(new_user_params)
  end

  private

  def new_user_params
    permitted_params = params.permit(:first_name, :last_name, :email, :password, :nationality, :phone_number)
    required_params = ["first_name", "last_name", "email", "password", "nationality", "phone_number"]
    missing_params = required_params.reject{ |req_param| permitted_params[req_param].present? }
    throw Exceptions::MissingParameters if missing_params.any?
    permitted_params
  end
end
