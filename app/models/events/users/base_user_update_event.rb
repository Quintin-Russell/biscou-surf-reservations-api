module Events
  module Users
    class BaseUserUpdateEvent < Event
      include UserEventConstants

      def self.event_type
        USER_UPDATED
      end

      def self.data_class
        Events::EventData::UserUpdateData
      end
    end
  end
end
