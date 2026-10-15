# frozen_string_literal: true

# Sidekiq args must be JSON-native, so the job receives the event id and reloads it
class EventBroadcastJob < BaseJob
  def perform(event_id)
    event = Event.find(event_id)

    case event.event_type
    when /^reservation\./
      Broadcasters::ReservationBroadcaster.new.perform(event)
    else
      Rails.logger.warn "#{event.event_type} not broadcasted"
    end
  end
end
