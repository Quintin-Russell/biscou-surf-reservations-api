module Events
  module Reservations
    class ReservationCancelEvent < BaseReservationEvent
      def self.event_type
        RESERVATION_UPDATE
      end

      def self.action
        CANCELED_ACTION
      end

      ## methods
    end
  end
end