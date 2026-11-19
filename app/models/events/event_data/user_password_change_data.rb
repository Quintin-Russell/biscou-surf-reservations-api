module Events
  module EventData
    class UserPasswordChangeData < BaseEventData
      ## Attributes
      attribute :user_id, :string

      ## Validations
      validate :user_exists?

      private

      def user_exists?
        errors.add(:user_id, "user_id must be a valid user") unless User.exists?(id: user_id)
      end
    end
  end
end
