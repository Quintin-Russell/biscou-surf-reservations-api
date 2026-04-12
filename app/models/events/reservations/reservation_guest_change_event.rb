module Events
  module Reservations
    class ReservationGuestChangeEvent < BaseReservationEvent
      private

      def event_type_name
        'reservation_update'
      end
      def action_name
        'guest_change'
      end

      ## methods
      # add a guest
      # remove a guest
      # validation: remove guest !== primary guest
    end
  end
end