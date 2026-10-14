require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let(:valid_attributes) do
    {
      first_name: 'John',
      last_name: 'Doe',
      email: 'john@surfretreat.com',
      password: 'SecurePass123',
      nationality: 'USA',
      phone_number: '+15551234567'
    }
  end

  def create_user(attrs = valid_attributes)
    post '/users/create', params: attrs, as: :json
  end

  describe 'POST /users/create' do
    context 'with valid parameters' do
      it 'creates a user without requiring authentication' do
        expect { create_user }.to change(User, :count).by(1)
        expect(response).to have_http_status(:ok)
      end

      it 'returns the serialized user' do
        create_user

        body = response.parsed_body
        expect(body).to include(
          'first_name' => 'John',
          'last_name' => 'Doe',
          'email' => 'john@surfretreat.com',
          'phone_number' => '+15551234567',
          'role' => 'guest'
        )
        expect(body.keys).not_to include('password', 'password_digest')
      end

      it 'hashes the password' do
        create_user

        user = User.last
        expect(user.password_digest).to be_present
        expect(user.password_digest).not_to eq('SecurePass123')
        expect(user.authenticate('SecurePass123')).to eq(user)
      end

      it 'logs the new user in (session row + cookie)' do
        expect { create_user }.to change(Session, :count).by(1)

        expect(Session.last.user).to eq(User.last)
        expect(cookies['session_id']).to be_present
      end

      it 'ignores privilege fields like role and permission' do
        create_user(valid_attributes.merge(role: 'employee', permission: 'admin'))

        user = User.last
        expect(user.role).to eq('guest')
        expect(user.permission).to eq('guest')
      end
    end

    context 'with missing parameters' do
      %i[first_name last_name email password nationality phone_number].each do |field|
        it "raises MissingParameters when #{field} is missing" do
          # TODO: becomes a 422 response once rescue_from Exceptions::BaseError is added (todo #9)
          expect { create_user(valid_attributes.except(field)) }
            .to raise_error(Exceptions::MissingParameters)
        end
      end
    end

    context 'with invalid values' do
      it 'returns 422 and creates no session for an invalid email' do
        expect { create_user(valid_attributes.merge(email: 'not-an-email')) }
          .not_to change(Session, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns 422 for a duplicate email' do
        create(:user, email: valid_attributes[:email])

        expect { create_user }.not_to change(User, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'not implemented yet (todo #16/#17)' do
      it 'normalizes email to lowercase' do
        pending 'add `normalizes :email` to User'
        create_user(valid_attributes.merge(email: 'JohnDoe@SurfRetreat.COM'))

        expect(User.last.email).to eq('johndoe@surfretreat.com')
      end

      it 'rejects passwords shorter than 8 characters' do
        pending 'add a password length validation to User'
        create_user(valid_attributes.merge(password: 'short'))

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns 201 Created' do
        pending 'render with status: :created in UsersController#create'
        create_user

        expect(response).to have_http_status(:created)
      end
    end
  end
end
