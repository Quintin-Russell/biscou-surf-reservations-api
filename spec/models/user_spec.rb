require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#management?' do
    it 'returns true for admin permission' do
      expect(build(:user, :admin_permission).management?).to be true
    end

    it 'returns true for manager permission' do
      expect(build(:user, :manager_permission).management?).to be true
    end

    %w[employee instructor guest].each do |permission|
      it "returns false for #{permission} permission" do
        expect(build(:user, permission: permission).management?).to be false
      end
    end

    it 'returns false for the default permission' do
      expect(build(:user).management?).to be false
    end

    it 'returns false when permission is nil' do
      expect(build(:user, permission: nil).management?).to be false
    end
  end
end
