module Events
  module Reservations
    class BaseReservationEvent < Event
      include ReservationConstants
      ## scopes
      scope :by_id, -> (reservation_id) { where("data->>'reservation_id' = ?", reservation_id) }
      scope :by_start_date, -> (start_date) { where("data->>'start_date' = ?", start_date.to_date.iso8601) }
      ## methods
      def self.create_event(params)
        create!({
          **params,
          event_type: event_type,
          action: action,
          processed_at: DateTime.current
        })
      end
    end
  end
end