# spec/controllers/users_controller_spec.rb
require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  # Use JSON format for all requests
  before do
    request.headers['Accept'] = 'application/json'
    request.headers['Content-Type'] = 'application/json'
  end

  describe 'POST #create' do
    # Valid user parameters
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

    # Missing parameters (each missing a different field)
    let(:missing_first_name) { valid_attributes.except(:first_name) }
    let(:missing_last_name) { valid_attributes.except(:last_name) }
    let(:missing_email) { valid_attributes.except(:email) }
    let(:missing_password) { valid_attributes.except(:password) }
    let(:missing_nationality) { valid_attributes.except(:nationality) }
    let(:missing_phone) { valid_attributes.except(:phone_number) }

    context 'with valid parameters' do
      it 'creates a new user' do
        expect {
          post :create, params: valid_attributes
        }.to change(User, :count).by(1)
      end

      it 'returns a 201 created status' do
        post :create, params: valid_attributes
        expect(response).to have_http_status(:created)
      end

      it 'returns the created user in JSON' do
        post :create, params: valid_attributes
        json_response = JSON.parse(response.body)

        expect(json_response['first_name']).to eq('John')
        expect(json_response['last_name']).to eq('Doe')
        expect(json_response['email']).to eq('john@surfretreat.com')
        expect(json_response['nationality']).to eq('USA')
        expect(json_response['phone_number']).to eq('+15551234567')
      end

      it 'does NOT return the password in JSON' do
        post :create, params: valid_attributes
        json_response = JSON.parse(response.body)

        expect(json_response).not_to have_key('password')
        expect(json_response).not_to have_key('password_digest')
      end

      it 'sets @current_user to the created user' do
        post :create, params: valid_attributes
        expect(assigns(:current_user)).to be_a(User)
        expect(assigns(:current_user).email).to eq('john@surfretreat.com')
      end

      it 'creates user with correct attributes' do
        post :create, params: valid_attributes
        user = User.last

        expect(user.first_name).to eq('John')
        expect(user.last_name).to eq('Doe')
        expect(user.email).to eq('john@surfretreat.com')
        expect(user.nationality).to eq('USA')
        expect(user.phone_number).to eq('+15551234567')
      end

      it 'hashes the password' do
        post :create, params: valid_attributes
        user = User.last

        expect(user.password_digest).to be_present
        expect(user.password_digest).not_to eq('SecurePass123')
      end
    end

    context 'with missing required parameters' do
      it 'raises MissingParameters error when first_name is missing' do
        expect {
          post :create, params: missing_first_name
        }.to raise_error(Exceptions::MissingParameters)
      end

      it 'raises MissingParameters error when last_name is missing' do
        expect {
          post :create, params: missing_last_name
        }.to raise_error(Exceptions::MissingParameters)
      end

      it 'raises MissingParameters error when email is missing' do
        expect {
          post :create, params: missing_email
        }.to raise_error(Exceptions::MissingParameters)
      end

      it 'raises MissingParameters error when password is missing' do
        expect {
          post :create, params: missing_password
        }.to raise_error(Exceptions::MissingParameters)
      end

      it 'raises MissingParameters error when nationality is missing' do
        expect {
          post :create, params: missing_nationality
        }.to raise_error(Exceptions::MissingParameters)
      end

      it 'raises MissingParameters error when phone_number is missing' do
        expect {
          post :create, params: missing_phone
        }.to raise_error(Exceptions::MissingParameters)
      end
    end

    context 'with invalid parameter values' do
      it 'fails when email format is invalid' do
        invalid_email_params = valid_attributes.merge(email: 'not-an-email')

        expect {
          post :create, params: invalid_email_params
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'fails when email already exists' do
        # Create first user
        post :create, params: valid_attributes

        # Try to create duplicate
        expect {
          post :create, params: valid_attributes
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'fails when password is too short' do
        short_password_params = valid_attributes.merge(password: 'short')

        expect {
          post :create, params: short_password_params
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'fails when first_name is blank' do
        blank_name_params = valid_attributes.merge(first_name: '')

        expect {
          post :create, params: blank_name_params
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'fails when phone_number format is invalid' do
        invalid_phone_params = valid_attributes.merge(phone_number: 'not-a-phone')

        expect {
          post :create, params: invalid_phone_params
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'with edge cases' do
      it 'handles names with special characters' do
        special_chars_params = valid_attributes.merge(
          first_name: "José María",
          last_name: "González-Smith"
        )

        expect {
          post :create, params: special_chars_params
        }.to change(User, :count).by(1)

        user = User.last
        expect(user.first_name).to eq("José María")
        expect(user.last_name).to eq("González-Smith")
      end

      it 'handles international phone numbers' do
        international_phone = valid_attributes.merge(
          phone_number: '+44 20 7946 0123'
        )

        post :create, params: international_phone
        user = User.last
        expect(user.phone_number).to eq('+44 20 7946 0123')
      end

      it 'normalizes email to lowercase' do
        uppercase_email = valid_attributes.merge(email: 'JohnDoe@SurfRetreat.COM')

        post :create, params: uppercase_email
        user = User.last
        expect(user.email).to eq('johndoe@surfretreat.com')
      end

      it 'strips whitespace from names' do
        whitespace_params = valid_attributes.merge(
          first_name: '  John  ',
          last_name: '  Doe  '
        )

        post :create, params: whitespace_params
        user = User.last
        expect(user.first_name).to eq('John')
        expect(user.last_name).to eq('Doe')
      end
    end

    context 'with additional parameters' do
      it 'ignores extra parameters' do
        extra_params = valid_attributes.merge(
          admin: true,
          role: 'superuser',
          unused_field: 'should be ignored'
        )

        post :create, params: extra_params
        user = User.last

        expect(user.first_name).to eq('John')
        expect(user.respond_to?(:admin)).to be_falsey
      end
    end

    context 'authentication' do
      it 'skips authentication for create action' do
        # This should NOT require a JWT token
        expect(controller).to_not receive(:authenticate_request)
        post :create, params: valid_attributes
        expect(response).to have_http_status(:created)
      end
    end

    context 'performance' do
      it 'creates user within reasonable time' do
        start_time = Time.current
        post :create, params: valid_attributes
        elapsed = Time.current - start_time

        expect(elapsed).to be < 0.5 # Should take less than 0.5 seconds
      end
    end
  end

  # Helper method for JSON parsing
  def json_response
    JSON.parse(response.body)
  end
end