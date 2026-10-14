module Events
  module Reservations
    class ReservationGuestRemovedEvent < BaseReservationEvent
      def self.event_type
        RESERVATION_UPDATE
      end

      def self.action
        GUEST_REMOVED_ACTION
      end

      ## methods
      # add a guest
      # remove a guest
      # validation: remove guest !== primary guest
    end
  end
end