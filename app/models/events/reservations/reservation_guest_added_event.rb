module Events
  module Reservations
    class ReservationGuestAddedEvent < BaseReservationEvent
      def self.event_type
        RESERVATION_UPDATE
      end

      def self.action
        GUEST_ADDED_ACTION
      end

      ## methods
      # add a guest
      # remove a guest
      # validation: remove guest !== primary guest
    end
  end
end