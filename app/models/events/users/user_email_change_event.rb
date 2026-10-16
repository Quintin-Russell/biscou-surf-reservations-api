module Events
  module Users
    class UserEmailChangeEvent < BaseUserUpdateEvent
      def self.action
        EMAIL_CHANGE_ACTION
      end
    end
  end
end
