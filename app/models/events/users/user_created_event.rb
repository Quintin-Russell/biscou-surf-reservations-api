module Events
  module Users
    class UserCreatedEvent < Event
      include UserEventConstants

      def self.event_type
        USER_CREATED
      end

      def self.action
        CREATED_ACTION
      end

      def self.data_class
        Events::EventData::UserCreatedData
      end
    end
  end
end
