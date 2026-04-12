module Events
  module Reservations
    class ReservationCheckinEvent < BaseReservationEvent
      private

      def event_type_name
        'reservation_update'
      end
      def action_name
        'checkin'
      end

      ## methods
    end
  end
end