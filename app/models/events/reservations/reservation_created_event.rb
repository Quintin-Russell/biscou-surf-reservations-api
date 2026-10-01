module Events
  module Reservations
    class ReservationCreatedEvent < BaseReservationEvent
      def self.event_type
        RESERVATION_CREATED
      end

      def self.action
        CREATED_ACTION
      end
    end
  end
end