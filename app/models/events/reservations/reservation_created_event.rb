module Events
  module Reservations
    class ReservationCreatedEvent < BaseReservationEvent
      private

      def event_type_name
        'reservation_created'
      end
      def action_name
        'created'
      end
    end
  end
end