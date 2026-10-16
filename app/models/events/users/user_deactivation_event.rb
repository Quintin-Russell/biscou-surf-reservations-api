module Events
  module Users
    class UserDeactivationEvent < BaseUserUpdateEvent
      def self.action
        DEACTIVATED_ACTION
      end
    end
  end
end
