module Events
  module Reservations
    class ReservationCancelEvent < BaseReservationEvent
      private

      def event_type
        'reservation_update'
      end
      def action
        'canceled'
      end

      ## methods
    end
  end
end