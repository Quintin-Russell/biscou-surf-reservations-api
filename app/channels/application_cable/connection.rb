# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user
    include AuthenticationConstants
    def connect
      self.current_user = find_verified_user || reject_unauthorized_connection
    end

    private

    def find_verified_user
      Session.find_active(cookies.signed[AUTH_FIELD_ON_COOKIE])&.user
    end
  end
end
