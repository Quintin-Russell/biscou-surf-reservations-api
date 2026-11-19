require 'rails_helper'

RSpec.describe 'Profiles', type: :request do
  let(:password) { 'Password123!' }
  let(:new_password) { 'NewPassword456!' }
  let!(:user) { create(:user, password: password) }

  def login
    post '/auth/login', params: { email: user.email, password: password }, as: :json
  end

  def change_password(current_password: password, new_password: self.new_password, confirm_password: self.new_password)
    patch "/profiles/#{user.id}/change_password",
          params: { current_password: current_password, new_password: new_password, confirm_password: confirm_password },
          as: :json
  end

  describe 'PATCH /profiles/:id/change_password' do
    context 'when authenticated' do
      before { login }

      it 'updates the password' do
        change_password

        expect(response).to have_http_status(:no_content)
        expect(user.reload.authenticate(new_password)).to be_truthy
        expect(user.authenticate(password)).to be(false)
      end

      it 'ends the current session and clears the cookie' do
        expect { change_password }.to change(Session, :count).by(-1)

        expect(cookies['session_id']).to be_blank
      end

      it "destroys the user's other sessions but not other users' sessions" do
        create(:session, user: user)
        other_user_session = create(:session)

        change_password

        expect(response).to have_http_status(:no_content)
        expect(user.sessions.count).to eq(0)
        expect(Session.exists?(other_user_session.id)).to be(true)
      end

      it 'revokes the session: replaying the old cookie returns 401' do
        old_cookie = cookies['session_id']

        change_password
        cookies['session_id'] = old_cookie
        get '/auth/current_user'

        expect(response).to have_http_status(:unauthorized)
      end

      it 'keeps the password and sessions when the event cannot be created' do
        allow(EventPublisher).to receive(:publish).and_raise(ActiveRecord::RecordInvalid)

        change_password

        expect(response).to have_http_status(:unprocessable_entity)
        expect(user.reload.authenticate(password)).to be_truthy
        expect(user.sessions.count).to eq(1)
      end

      it 'rejects an incorrect current password without changing anything' do
        expect { change_password(current_password: 'WrongPassword!') }.not_to change(Event, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['error']).to eq('Current password is incorrect')
        expect(user.reload.authenticate(password)).to be_truthy
        expect(user.sessions.count).to eq(1)
      end

      it 'rejects a missing current password' do
        patch "/profiles/#{user.id}/change_password",
              params: { new_password: new_password, confirm_password: new_password }, as: :json

        expect(response).to have_http_status(:bad_request)
        expect(user.reload.authenticate(password)).to be_truthy
      end

      it 'keeps the session when the passwords do not match' do
        expect { change_password(confirm_password: 'Different789!') }.not_to change(Session, :count)

        get '/auth/current_user'
        expect(response).to have_http_status(:ok)
      end

      it 'logs a password changed event with only the user id' do
        expect { change_password }.to change(Events::Users::UserPasswordChangeEvent, :count).by(1)

        event = Events::Users::UserPasswordChangeEvent.last
        expect(event.event_type).to eq(UserEventConstants::USER_UPDATED)
        expect(event.action).to eq(UserEventConstants::PASSWORD_CHANGE_ACTION)
        expect(event.data).to eq('user_id' => user.id)
      end

      it 'rejects mismatched passwords without changing anything' do
        expect { change_password(confirm_password: 'Different789!') }.not_to change(Event, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['error']).to eq('Passwords do not match')
        expect(user.reload.authenticate(password)).to be_truthy
      end

      it 'rejects a missing confirmation' do
        patch "/profiles/#{user.id}/change_password", params: { new_password: new_password }, as: :json

        expect(response).to have_http_status(:bad_request)
        expect(user.reload.authenticate(password)).to be_truthy
      end
    end

    context 'when unauthenticated' do
      it 'returns 401 and does not change the password' do
        change_password

        expect(response).to have_http_status(:unauthorized)
        expect(user.reload.authenticate(password)).to be_truthy
      end
    end
  end
end
