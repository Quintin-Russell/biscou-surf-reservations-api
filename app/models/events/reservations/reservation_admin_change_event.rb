module Events
  module Reservations
    class ReservationAdminChangeEvent < BaseReservationEvent
      private

      def event_type
        'reservation_update'
      end
      def action
        'admin_change'
      end

      ## methods
      # change reservation manager
      # change primary guest
    end
  end
end