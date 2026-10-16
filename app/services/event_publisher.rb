# frozen_string_literal: true

class EventPublisher
  class << self
    # Persists the event synchronously so callers only get a response once the
    # event is durable. The event is added to the Redis stream after commit (see Event#publish_to_stream).
    def publish(event_class:, event_data:)
      raise Exceptions::MissingEventParametersError unless event_class.present? && event_data.present?

      Event.transaction do
        event_class.create_event(event_data:)
      end
    end
  end
end
