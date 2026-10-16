module Events
  module EventData
    class UserUpdateData < BaseEventData
      ## Attributes
      attribute :user_id, :string
      attribute :previous_values
      attribute :current_values
      attribute :updator, :string

      ## Validations
      validate user_exists?
      validate updator_exists?

      validates :current_values, presence: true
      validates :previous_values, presence: true

      private

      def user_exists?
        erros.add(:user_id, "user_id must be a valid user") unless User.exists?(id: user_id)
      end

      def updator_exists?
        erros.add(:updator, "updator must be a valid user") unless User.exists?(id: updator)
      end
    end
  end
end
