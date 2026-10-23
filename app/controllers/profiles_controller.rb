class ProfilesController < ApplicationController
  def update
    @user = UpdateUserService.perform(user_id: current_user.id, params: update_user_params, updator: current_user.id)
  end

  def show
    @user = current_user
  end

  private

  def update_user_params
    params.permit(:first_name, :last_name, :email, :nationality, :phone_number)
  end
end
