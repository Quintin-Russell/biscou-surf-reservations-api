module Events
  module Users
    class UserPhoneNumberChangeEvent < BaseUserUpdateEvent
      def self.action
        PHONE_NUMBER_CHANGE_ACTION
      end
    end
  end
end
