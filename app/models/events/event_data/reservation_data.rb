# frozen_string_literal: true
module Events
  module EventData
    class ReservationData < BaseEventData
      include ReservationConstants

      ## attributes
      attribute :reservation_id, :string
      attribute :start_date, :date
      attribute :end_date, :date
      attribute :paid, :boolean, default: false
      attribute :price, :integer
      attribute :notes, :string
      attribute :status, :string, default: STATUS_PENDING

      # user ids (uuid)
      attribute :primary_guest, :string
      attribute :reservation_manager, :string

      # ActiveModel has no array type: untyped attributes pass values through as-is
      attribute :guests, default: -> { [] }
      attribute :activities, default: -> { [] }
      attribute :accommodation, :string

      ## validations
      # :date casts unparseable strings to nil, so presence also rejects invalid dates
      validates :reservation_id, :price, :primary_guest, :reservation_manager, :accommodation,
                :start_date, :end_date, presence: true
      # presence would reject false
      validates :paid, inclusion: { in: [true, false] }
      validates :price, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
      validates :status, inclusion: { in: ALL_STATUSES }

      validate :end_date_after_start_date
      validate :primary_guest_exists
      validate :reservation_manager_exists

      private

      def end_date_after_start_date
        return unless start_date && end_date
        errors.add(:end_date, 'must be after start date') unless end_date > start_date
      end

      def primary_guest_exists
        return if primary_guest.blank?
        errors.add(:primary_guest, 'does not exist') unless User.exists?(id: primary_guest)
        errors.add(:primary_guest, 'must be one of the guests') unless Array(guests).include?(primary_guest)
      end

      def reservation_manager_exists
        return if reservation_manager.blank?
        errors.add(:reservation_manager, 'does not exist') unless User.exists?(id: reservation_manager)
      end
    end
  end
end
