# frozen_string_literal: true
class UserSerializer
  def initialize(user)
    @user = user
  end

  def safe_json
    {
      id: @user.id,
      email: @user.email,
      first_name: @user.first_name,
      last_name: @user.last_name,
      full_name: "#{@user.first_name} #{@user.last_name}",
      role: @user.role,
      phone_number: @user.phone_number,
      created_at: @user.created_at,
      is_management: UserRolesConstants::EMPLOYEE_ROLE == @user.role && UserPermissionsConstants::MANAGEMENT_PERMISSIONS.include?(@user.permission)
    }
  end
end
