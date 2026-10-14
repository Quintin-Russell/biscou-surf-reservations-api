module Events
  module Reservations
    class ReservationCheckoutEvent < BaseReservationEvent
      def self.event_type
        RESERVATION_UPDATE
      end

      def self.action
        CHECKOUT_ACTION
      end

      ## methods
    end
  end
end