module Events
  module Reservations
    class ReservationCreatedEvent < BaseReservationEvent
      private

      def self.event_type
        'reservation_created'
      end
      def self.action
        'created'
      end
    end
  end
end