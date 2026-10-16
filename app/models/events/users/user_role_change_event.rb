module Events
  module Users
    class UserRoleChangeEvent < BaseUserUpdateEvent
      def self.action
        ROLE_CHANGE_ACTION
      end
    end
  end
end
