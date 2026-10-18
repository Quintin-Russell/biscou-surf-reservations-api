# frozen_string_literal: true

class CreateUserService
  class << self
    def perform(params:, created_by: nil)
      User.transaction do
        user = User.create!(params)

        event_data = Events::EventData::UserCreatedData.new(user_id: user.id, created_by: created_by || user.id)
        EventPublisher.publish(
          event_class: Events::Users::UserCreatedEvent,
          event_data: event_data
        )
        user
      end
    end
  end
end
