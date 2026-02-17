# frozen_string_literal: true

class EventPublisher
  class << self
    def publish(event_type:, action:, payload: {}, options: {})
      create_event(event_type:, action:, payload:)
      # publish update if necessary
      handle_broadcast
      @event
    end

    def create_event(event_type:, action:, payload:)
      raise Exceptions::MissingEventParametersError unless event_type.present? && payload.present?
      # make event
      @event = make_standard_event(event_type:, action:, payload:)
      # store event
      EventStorageJob.perform_async(@event)
    end

    def handle_broadcast
      case @event.event_type
      when /^reservation\./
        ReservationBroadcaster.perform_later(@event)
      when /^user\./
        UserBroadcaster.perform_later(@event)
      when /^activity\./
        ActivityBroadcaster.perform_later(@event)
      else
        Rails.logger.warn "#{@event.event_type} not broadcasted"
      end
    end

    private

    def make_standard_event(event_type:, action:, payload:)
      {
        event_type:,
        action:,
        data: payload,
        source: 'api'
      }
    end
  end
end
