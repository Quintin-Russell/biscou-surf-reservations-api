# frozen_string_literal: true

class EventPublisher
  class << self
    # Persists the event synchronously so callers only get a response once the
    # event is durable. Broadcasting is enqueued after commit (see Event#enqueue_broadcast).
    def publish(event_class:, data: {})
      raise Exceptions::MissingEventParametersError unless event_class.present? && data.present?

      Event.transaction do
        event_class.create_event(data:)
      end
    end
  end
end
