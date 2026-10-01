module Events
  module Reservations
    class ReservationAdminChangeEvent < BaseReservationEvent
      def self.event_type
        RESERVATION_UPDATE
      end

      def self.action
        ADMIN_CHANGE_ACTION
      end

      ## methods
      # change reservation manager
      # change primary guest
    end
  end
end