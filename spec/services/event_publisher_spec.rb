# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventPublisher do
  let(:event_class) { Events::Reservations::ReservationCancelEvent }
  let(:event_data) { build(:reservation_data, reservation_id: 'res-1') }

  describe '.publish' do
    it 'persists and returns the event' do
      event = described_class.publish(event_class:, event_data:)

      expect(event).to be_a(event_class).and be_persisted
      expect(event.reload.data).to eq(event_data.attributes.as_json)
    end

    it 'enqueues a broadcast for the new event' do
      event = described_class.publish(event_class:, event_data:)

      expect(EventBroadcastJob.jobs.map { |job| job['args'] }).to eq([[event.id]])
    end

    it 'raises when event_class is missing' do
      expect { described_class.publish(event_class: nil, event_data:) }
        .to raise_error(Exceptions::MissingEventParametersError)
    end

    it 'raises when event_data is missing' do
      expect { described_class.publish(event_class:, event_data: nil) }
        .to raise_error(Exceptions::MissingEventParametersError)
    end

    it 'does not persist or enqueue when creation fails' do
      allow(event_class).to receive(:create_event).and_raise(ActiveRecord::RecordInvalid)

      expect { described_class.publish(event_class:, event_data:) }.to raise_error(ActiveRecord::RecordInvalid)
      expect(Event.count).to eq(0)
      expect(EventBroadcastJob.jobs).to be_empty
    end
  end
end
