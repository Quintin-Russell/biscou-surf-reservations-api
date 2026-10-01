module Events
  module Reservations
    class ReservationAccommodationChangeEvent < BaseReservationEvent
      def self.event_type
        RESERVATION_UPDATE
      end

      def self.action
        ACCOMMODATION_UPDATE_ACTION
      end

      ## methods
      # change accommodation
    end
  end
end