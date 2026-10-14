# frozen_string_literal: true

module Authentication
    extend ActiveSupport::Concern
    include AuthenticationConstants

    included do
        before_action :require_authentication
    end

    class_methods do
        ## options is designed so that `only` or `except` can be forwarded to skip_before_action on a case-by-case basis
        def allow_unauthorized_access(**options)
            skip_before_action :require_authentication, **options
        end
    end

    private

    def current_user
        Current.user
    end

    def require_authentication
        has_session || render(json: { error: "Unauthorized" }, status: :unauthorized)
    end
    # checks to see if current session is cached on Current or an active session exists with info from token => sets current.session
    def has_session
        Current.session ||= Session.find_active(cookies.signed[AUTH_FIELD_ON_COOKIE])
    end
    # called after user login and password are confirmed
    def start_new_session(user)
        end_session if has_session
        ## create session
        user.sessions.create!(ip_address: request.remote_ip).tap do |new_session|
            Current.session = new_session
        ## use session_id to create a cookie; all other data stays in DB
            cookies.signed[AUTH_FIELD_ON_COOKIE] = auth_cookie_options.merge(
                value: new_session.id,
                expires: new_session.expires_at
            )
        end
    end

    def end_session
        user = current_user
        Current.session&.destroy
        cookies.delete(AUTH_FIELD_ON_COOKIE, **auth_cookie_options)
        end_session_cleanup(user)
    end

    def auth_cookie_options
        cross_origin = Rails.env.development? && request.headers["Origin"]&.present?
        {
            httponly: true,
            secure: Rails.env.production? || cross_origin,
            same_site: cross_origin ? :none : :lax
        }
    end

    def end_session_cleanup(user)
        Current.session = nil
        destroy_connections(user)
    end

    def destroy_connections(user)
        ActionCable.server.remote_connections.where(current_user: user).disconnect
        rescue StandardError => e
            Rails.logger.warn "ActionCable disconnect failed for user #{user.id}: #{e.class}"
    end
end
