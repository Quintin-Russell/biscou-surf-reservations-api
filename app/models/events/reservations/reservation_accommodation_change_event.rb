module Events
  module Reservations
    class ReservationAccommodationChangeEvent < BaseReservationEvent
      private

      def event_type_name
        'reservation_update'
      end
      def action_name
        'accommodation_change'
      end

      ## methods
      # change accommodation
    end
  end
end