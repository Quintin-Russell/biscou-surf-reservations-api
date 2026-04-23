module Events
  module Reservations
    class ReservationGuestRemovedEvent < BaseReservationEvent
      private

      def event_type
        'reservation_update'
      end
      def action
        'guest_removed'
      end

      ## methods
      # add a guest
      # remove a guest
      # validation: remove guest !== primary guest
    end
  end
end