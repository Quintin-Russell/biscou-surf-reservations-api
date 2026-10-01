# frozen_string_literal: true

class EventStorageJob < BaseJob
  def perform(event_type:, payload:)
    case event_type
    when /^reservation\./

      data = Events::EventData::ReservationData.create!(payload)

    when /^user\./
    when /^activity\./
    else
      Rails.logger.warn "#{@event.event_type} not broadcasted"
    end
  end
end
