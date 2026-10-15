# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventPublisher do
  let(:event_class) { Events::Reservations::ReservationCancelEvent }
  let(:data) { { reservation_id: 'res-1' } }

  describe '.publish' do
    it 'persists and returns the event' do
      event = described_class.publish(event_class:, data:)

      expect(event).to be_a(event_class).and be_persisted
      expect(event.data).to eq('reservation_id' => 'res-1')
    end

    it 'enqueues a broadcast for the new event' do
      event = described_class.publish(event_class:, data:)

      expect(EventBroadcastJob.jobs.map { |job| job['args'] }).to eq([[event.id]])
    end

    it 'raises when event_class is missing' do
      expect { described_class.publish(event_class: nil, data:) }
        .to raise_error(Exceptions::MissingEventParametersError)
    end

    it 'raises when data is empty' do
      expect { described_class.publish(event_class:, data: {}) }
        .to raise_error(Exceptions::MissingEventParametersError)
    end

    it 'does not persist or enqueue when creation fails' do
      allow(event_class).to receive(:create_event).and_raise(ActiveRecord::RecordInvalid)

      expect { described_class.publish(event_class:, data:) }.to raise_error(ActiveRecord::RecordInvalid)
      expect(Event.count).to eq(0)
      expect(EventBroadcastJob.jobs).to be_empty
    end
  end
end
