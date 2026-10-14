require 'rails_helper'

RSpec.describe 'Auth', type: :request do
  let(:password) { 'Password123!' }
  let!(:user) { create(:user, password: password) }

  def login(email: user.email, pass: password)
    post '/auth/login', params: { email: email, password: pass }, as: :json
  end

  def set_cookie_header
    Array(response.headers['set-cookie']).join("\n")
  end

  describe 'POST /auth/login' do
    context 'with valid credentials' do
      it 'returns 200 with the serialized user' do
        login

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body['id']).to eq(user.id)
        expect(body['email']).to eq(user.email)
        expect(body['role']).to eq(user.role)
      end

      it 'never exposes password fields' do
        login

        expect(response.parsed_body.keys).not_to include('password', 'password_digest')
      end

      it 'creates a session row for the user' do
        expect { login }.to change { user.sessions.count }.by(1)
        expect(user.sessions.last.ip_address.to_s).to be_present
      end

      it 'sets an httponly, SameSite=Lax session cookie' do
        login

        expect(cookies[AuthenticationConstants::AUTH_FIELD_ON_COOKIE.to_s]).to be_present
        expect(set_cookie_header).to match(/session_id=/)
        expect(set_cookie_header).to match(/httponly/i)
        expect(set_cookie_header).to match(/samesite=lax/i)
      end

      it 'replaces an existing session instead of reusing it (session fixation)' do
        login
        old_session_id = Session.last.id

        login

        expect(Session.exists?(old_session_id)).to be(false)
        expect(user.sessions.count).to eq(1)
      end
    end

    context 'with invalid credentials' do
      it 'returns 401 for a wrong password and creates no session' do
        expect { login(pass: 'wrong') }.not_to change(Session, :count)

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body['error']).to eq('Invalid email or password')
        expect(cookies['session_id']).to be_blank
      end

      it 'returns 401 for an unknown email' do
        login(email: 'nobody@example.com')

        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns 400 when password is missing' do
        post '/auth/login', params: { email: user.email }, as: :json

        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'protected endpoints (GET /auth/current_user)' do
    it 'returns 200 and the current user when logged in' do
      login

      get '/auth/current_user'

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['id']).to eq(user.id)
      expect(response.parsed_body.keys).not_to include('password_digest')
    end

    it 'returns 401 without a cookie' do
      get '/auth/current_user'

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 401 when the session has expired' do
      login
      Session.last.update!(expires_at: 1.minute.ago)

      get '/auth/current_user'

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 401 when the session row was revoked server-side' do
      login
      Session.last.destroy

      get '/auth/current_user'

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 401 for a tampered cookie' do
      cookies['session_id'] = 'forged-value'

      get '/auth/current_user'

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /auth/logout' do
    it 'returns 204, deletes the session row, and clears the cookie' do
      login

      expect { post '/auth/logout' }.to change(Session, :count).by(-1)
      expect(response).to have_http_status(:no_content)
      expect(cookies['session_id']).to be_blank
    end

    it 'revokes the session: replaying the old cookie returns 401' do
      login
      stolen_cookie = cookies['session_id']

      post '/auth/logout'
      cookies['session_id'] = stolen_cookie
      get '/auth/current_user'

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 204 even without a valid session (idempotent logout)' do
      post '/auth/logout'

      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'GET /auth/email_exists (public, used by signup)' do
    it 'returns true for a registered email without logging in' do
      get '/auth/email_exists', params: { email: user.email }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to be(true)
    end

    it 'returns false for an unregistered email' do
      get '/auth/email_exists', params: { email: 'nobody@example.com' }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to be(false)
    end

    describe 'rate limiting (10 requests per 10 minutes per IP)' do
      # The test env uses :null_store, which never counts, so route the
      # controller's rate-limit counter through a real in-memory store.
      let(:memory_store) { ActiveSupport::Cache::MemoryStore.new }

      before do
        allow(Auth::AuthController.cache_store).to receive(:increment) do |*args, **kwargs|
          memory_store.increment(*args, **kwargs)
        end
      end

      def check_email(ip: '1.2.3.4')
        get '/auth/email_exists',
            params: { email: user.email },
            headers: { 'Accept' => 'application/json', 'REMOTE_ADDR' => ip }
      end

      it 'allows 10 requests, then returns 429 on the 11th' do
        10.times do |i|
          check_email
          expect(response).not_to have_http_status(:too_many_requests), "request #{i + 1} was rate limited"
        end

        check_email

        expect(response).to have_http_status(:too_many_requests)
        expect(response.parsed_body['error']).to eq('Too many attempts')
      end

      it 'counts each IP separately' do
        11.times { check_email(ip: '1.1.1.1') }
        expect(response).to have_http_status(:too_many_requests)

        check_email(ip: '2.2.2.2')

        expect(response).not_to have_http_status(:too_many_requests)
      end

      it 'resets after the window expires' do
        11.times { check_email }
        expect(response).to have_http_status(:too_many_requests)

        travel 10.minutes + 1.second
        check_email

        expect(response).not_to have_http_status(:too_many_requests)
      end
    end
  end
end
