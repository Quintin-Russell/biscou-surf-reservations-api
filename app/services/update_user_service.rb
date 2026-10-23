# frozen_string_literal: true

class UpdateUserService
  class << self
    def perform(user_id:, params:, updator:)
      User.transaction do
        user = User.find(user_id)
        fields = params.keys.map(&:to_s)
        previous_values = user.attributes.slice(*fields)
        user.update!(params)

        event_data = Events::EventData::UserUpdateData.new(
          user_id: updator,
          previous_values:,
          current_values: user.attributes.slice(*fields)
        )
        EventPublisher.publish(
          event_class: Events::Users::BaseUserUpdateEvent,
          event_data:
        )

        user
      end
    end
  end
end
