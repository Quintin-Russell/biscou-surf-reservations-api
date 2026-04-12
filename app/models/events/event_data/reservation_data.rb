# frozen_string_literal: true
module Events
  module EventData
    class ReservationData < BaseEventData
      include ReservationStatusesConstants

      ## attributes
      attribute reservation_id: String
      attribute start_date: Date
      attribute end_date: Date
      attribute paid: Boolean, default: false
      attribute price: Integer
      attribute notes: String
      attribute status: String, default: 'pending'

      attribute primary_guest: String
      attribute reservation_manager: String

      attribute guests: Array[String]
      attribute activities: Array[String]
      attribute accommodation: String

      ## validations
      validates :reservation_id, :price, :paid, :primary_guest, :reservation_manager, :accommodation, presence: true
      validates :start_date, :end_date, presence: true, date: true

      validates :price, numericality: { greater_than: 0 }

      validates :status, inclusion: { in: ALL_STATUSES }

      validates :primary_guest_exists?
      validates :reservation_manager_exists?
      validates :end_date_after_start_date

      ## methods
      private
      def end_date_after_start_date
        start_date && end_date && (end_date - start_date).to_i > 0
      end

      def primary_guest_exists?
        User.exists?(primary_guest) && guests.any? { |guest| guest == primary_guest }
      end

      def reservation_manager_exists?
        User.exists?(reservation_manager)
      end
    end
  end
end

