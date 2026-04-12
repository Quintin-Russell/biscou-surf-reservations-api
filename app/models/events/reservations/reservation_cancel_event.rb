module Events
  module Reservations
    class ReservationCancelEvent < BaseReservationEvent
      private

      def event_type_name
        'reservation_update'
      end
      def action_name
        'canceled'
      end

      ## methods
    end
  end
end