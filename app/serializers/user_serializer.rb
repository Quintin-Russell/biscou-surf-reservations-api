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
      phone_number: @user.phone_number,
      created_at: @user.created_at
    }
  end
end