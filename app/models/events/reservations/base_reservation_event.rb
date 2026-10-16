module Events
  module Reservations
    class BaseReservationEvent < Event
      include ReservationConstants
      def self.data_class
        Events::EventData::ReservationData
      end

      ## scopes
      scope :by_id, ->(reservation_id) { where("data->>'reservation_id' = ?", reservation_id) }
      scope :by_start_date, ->(start_date) { where("data->>'start_date' = ?", start_date.to_date.iso8601) }
      ## getters: search payload for
      # guest names
      # accommodation
    end
  end
end
