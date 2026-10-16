module Events
  module Users
    class UserNationalityChangeEvent < BaseUserUpdateEvent
      def self.action
        NATIONALITY_CHANGE_ACTION
      end
    end
  end
end
