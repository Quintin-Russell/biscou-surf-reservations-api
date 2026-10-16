# frozen_string_literal: true

class CreateUserService
  class << self
    def perform(params, created_by = nil)
      User.transaction do
        user = User.create!(params)

        creator = created_by || user.id
        event_data = Events::EventData::UserCreatedData.new(user_id: user.id, created_by: creator)

        EventPublisher.publish(
          event_class: Events::Users::UserCreatedEvent,
          event_data: event_data
        )
        user
      end
    end
  end
end
