module Events
  module Users
    class UserPasswordChangeEvent < BaseUserUpdateEvent
      def self.action
        PASSWORD_CHANGE_ACTION
      end

      def self.data_class
        Events::EventData::UserPasswordChangeData
      end
    end
  end
end
