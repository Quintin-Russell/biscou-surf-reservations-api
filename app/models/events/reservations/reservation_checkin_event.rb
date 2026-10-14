module Events
  module Reservations
    class ReservationCheckinEvent < BaseReservationEvent
      def self.event_type
        RESERVATION_UPDATE
      end

      def self.action
        CHECKIN_ACTION
      end

      ## methods
    end
  end
end