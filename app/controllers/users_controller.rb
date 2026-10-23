class UsersController < ApplicationController
  allow_unauthorized_access only: %i[ signup ]
  before_action :require_employee_role, only: %i[ create show ]
  before_action :require_manager_permission, only: %i[ index update ]
  rate_limit to: 10, within: 1.minutes, name: "signup-attempt", only: :signup,
      with: -> { render json: { error: "Too many attempts" }, status: :too_many_requests }

  def signup
    @user = CreateUserService.perform(params: new_user_params)
    start_new_session(@user)
    render :create
  end

  def create
    @user = CreateUserService.perform(params: new_user_params(:role, :permission), created_by: current_user.id)
  end

  def update
    @user = UpdateUserService.perform(user_id: params[:id], params: update_user_params, updator: current_user.id)
  end

  def index
    @users = User.all
  end

  private

  def new_user_params(*extra_permitted)
    permitted_params = params.permit(:first_name, :last_name, :email, :password, :nationality, :phone_number, *extra_permitted)
    required_params = [ "first_name", "last_name", "email", "password", "nationality", "phone_number" ]
    missing_params = required_params.reject { |req_param| permitted_params[req_param].present? }
    raise Exceptions::MissingParameters if missing_params.any?
    permitted_params
  end

  def update_user_params
    params.permit(:first_name, :last_name, :email, :nationality, :phone_number, :role, :permission)
  end

  def require_employee_role
    is_employee = current_user.role == UserRolesConstants::EMPLOYEE_ROLE
    render json: { error: "Forbidden" }, status: :forbidden unless is_employee
  end

  def require_manager_permission
    render json: { error: "Forbidden" }, status: :forbidden unless current_user.management?
  end
end
