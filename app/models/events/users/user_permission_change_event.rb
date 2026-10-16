module Events
  module Users
    class UserPermissionChangeEvent < BaseUserUpdateEvent
      def self.action
        PERMISSION_CHANGE_ACTION
      end
    end
  end
end
