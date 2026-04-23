module Events
  module Reservations
    class ReservationAccommodationChangeEvent < BaseReservationEvent
      private
      def event_type
        'reservation_update'
      end
      def action
        'accommodation_change'
      end

      ## methods
      # change accommodation
    end
  end
end