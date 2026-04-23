module Events
  module Reservations
    class BaseReservationEvent < Event
      ## scopes
      scope :by_id, -> (reservation_id) { where("reservation_id = ?", reservation_id) }
      scope :by_start_date, -> (start_date) { where("start_date = ?", start_date) }
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