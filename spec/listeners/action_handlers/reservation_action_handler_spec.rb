# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReservationActionHandler do
  describe '#process_action' do
    it "handles reservation created events" do
      expect(described_class).to receive(:handle_reservation_created)
      described_class.process_action(build(:event, :reservation_created).action)
    end

    it "handles reservation canceled events" do
      expect(described_class).to receive(:handle_reservation_canceled)
      described_class.process_action(build(:event, :reservation_canceled).action)
    end

    it "handles reservation check in events" do
      expect(described_class).to receive(:handle_reservation_checkin)
      described_class.process_action(build(:event, :reservation_checkin).action)
    end

    it "handles reservation check out events" do
      expect(described_class).to receive(:handle_reservation_checkout)
      described_class.process_action(build(:event, :reservation_checkout).action)
    end

    it "handles reservation guest change events" do
      expect(described_class).to receive(:handle_reservation_guest_change)
      described_class.process_action(build(:event, :reservation_guest_change).action)
    end

    it "handles reservation activity change events" do
      expect(described_class).to receive(:handle_reservation_activity_change)
      described_class.process_action(build(:event, :reservation_activity_change).action)
    end

    it "handles reservation admin change events" do
      expect(described_class).to receive(:handle_reservation_admin_change)
      described_class.process_action(build(:event, :reservation_admin_change).action)
    end

    it "handles reservation accommodation change events" do
      expect(described_class).to receive(:handle_reservation_accommodation_change)
      described_class.process_action(build(:event, :reservation_accommodation_change).action)
    end
  end
end
# create redis => make thread
# put message in thread
  # types of message for tests: event[:action] = ['created', 'updated', 'checkin', 'checkout']
