require 'rails_helper'

RSpec.describe Session, type: :model do
  describe 'factory' do
    it 'builds a valid session' do
      expect(build(:session)).to be_valid
    end
  end

  describe 'validations' do
    it 'requires a user' do
      session = build(:session, user: nil)

      expect(session).not_to be_valid
      expect(session.errors[:user]).to include('must exist')
    end

    it 'requires expires_at' do
      session = build(:session, expires_at: nil)

      expect(session).not_to be_valid
      expect(session.errors[:expires_at]).to include("can't be blank")
    end
  end

  describe 'expires_at default' do
    it 'defaults to AUTH_DURATION from now' do
      freeze_time do
        session = Session.new

        expect(session.expires_at).to eq(AuthenticationConstants::AUTH_DURATION.from_now)
      end
    end

    it 'is evaluated per instance, not once at class load' do
      # Proc defaults are evaluated lazily on first read, so read before traveling.
      first_expires_at = Session.new.expires_at
      travel 1.hour
      second_expires_at = Session.new.expires_at

      expect(second_expires_at - first_expires_at).to be_within(1.second).of(1.hour)
    end
  end

  describe '.active' do
    it 'includes unexpired sessions and excludes expired ones' do
      active = create(:session)
      expired = create(:session, :expired)

      expect(Session.active).to include(active)
      expect(Session.active).not_to include(expired)
    end
  end

  describe '.find_active' do
    it 'returns an active session by id' do
      session = create(:session)

      expect(Session.find_active(session.id)).to eq(session)
    end

    it 'returns nil for an expired session' do
      session = create(:session, :expired)

      expect(Session.find_active(session.id)).to be_nil
    end

    it 'returns nil for an unknown id' do
      expect(Session.find_active(SecureRandom.uuid)).to be_nil
    end

    it 'returns nil for a nil id' do
      expect(Session.find_active(nil)).to be_nil
    end
  end

  describe '#expired?' do
    it 'is false before expires_at' do
      expect(build(:session)).not_to be_expired
    end

    it 'is true after expires_at' do
      expect(build(:session, :expired)).to be_expired
    end
  end

  describe 'database constraints' do
    it 'deletes sessions when the user is deleted (ON DELETE CASCADE)' do
      session = create(:session)

      expect { session.user.destroy }.to change(Session, :count).by(-1)
    end

    it 'rejects a user_id that does not exist (foreign key)' do
      session = build(:session, user_id: SecureRandom.uuid)

      expect { session.save!(validate: false) }.to raise_error(ActiveRecord::InvalidForeignKey)
    end

    it 'rejects a null expires_at at the DB level' do
      session = build(:session, expires_at: nil)

      expect { session.save!(validate: false) }.to raise_error(ActiveRecord::NotNullViolation)
    end
  end
end
