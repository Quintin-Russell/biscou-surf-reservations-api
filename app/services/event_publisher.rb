# frozen_string_literal: true

class EventPublisher
  class << self
    def publish(event_class:, event_data:)
      raise Exceptions::MissingEventParametersError unless event_class.present? && event_data.present?

      Event.transaction do
        event_class.create_event(event_data:)
      end
    end
  end
end
