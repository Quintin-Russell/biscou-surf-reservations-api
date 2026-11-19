class ProfilesController < ApplicationController
  def update
    @user = UpdateUserService.perform(user_id: current_user.id, params: update_user_params, updator: current_user.id)
  end

  def change_password
    ChangePasswordService.perform(
      user_id: current_user.id,
      current_password: params.require(:current_password),
      new_password: params.require(:new_password),
      confirm_password: params.require(:confirm_password)
    )
    end_session
    head :no_content
  rescue Exceptions::PasswordsDoNotMatch, Exceptions::IncorrectPassword => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def show
    @user = current_user
  end

  private

  def update_user_params
    params.permit(:first_name, :last_name, :email, :nationality, :phone_number)
  end
end
