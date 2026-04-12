module Events
  module Reservations
    class ReservationCheckoutEvent < BaseReservationEvent
      private

      def event_type_name
        'reservation_update'
      end
      def action_name
        'checkout'
      end

      ## methods
    end
  end
end