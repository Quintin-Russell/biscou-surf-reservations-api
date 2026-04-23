module Events
  module Reservations
    class ReservationCheckoutEvent < BaseReservationEvent
      private

      def event_type
        'reservation_update'
      end
      def action
        'checkout'
      end

      ## methods
    end
  end
end