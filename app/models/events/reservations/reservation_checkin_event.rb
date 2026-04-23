module Events
  module Reservations
    class ReservationCheckinEvent < BaseReservationEvent
      private

      def event_type
        'reservation_update'
      end
      def action
        'checkin'
      end

      ## methods
    end
  end
end