module Events
  module Users
    class UserNameChangeEvent < BaseUserUpdateEvent
      def self.action
        NAME_CHANGE_ACTION
      end
    end
  end
end
