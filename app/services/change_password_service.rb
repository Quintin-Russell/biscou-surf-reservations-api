# frozen_string_literal: true

class ChangePasswordService
  class << self
    def perform(user_id:, current_password:, new_password:, confirm_password:)
      raise Exceptions::PasswordsDoNotMatch unless new_password == confirm_password

      User.transaction do
        user = User.find(user_id)
        raise Exceptions::IncorrectPassword unless user.authenticate(current_password)

        user.update!(password: new_password)
        user.sessions.destroy_all

        EventPublisher.publish(
          event_class: Events::Users::UserPasswordChangeEvent,
          event_data: Events::EventData::UserPasswordChangeData.new(user_id:)
        )

        user
      end
    end
  end
end
