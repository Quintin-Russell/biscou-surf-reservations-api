module Events
  module Reservations
    class ReservationGuestAddedEvent < BaseReservationEvent
      private

      def event_type
        'reservation_update'
      end
      def action
        'guest_added'
      end

      ## methods
      # add a guest
      # remove a guest
      # validation: remove guest !== primary guest
    end
  end
end