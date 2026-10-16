module Events
  module EventData
    class UserCreatedData < BaseEventData
      ## Attributes
      attribute :user_id, :string
      attribute :created_by, :string

      ## Validations
      validate :created_by_exists
      validates :user_id, presence: true

      private

      def created_by_exists
        errors.add(:created_by, "doesn't exist") unless created_by.present? && User.exists?(id: created_by)
      end
    end
  end
end
