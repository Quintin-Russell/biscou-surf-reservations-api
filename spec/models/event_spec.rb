# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event do
  let(:event_class) { Events::Reservations::ReservationCreatedEvent }
  let(:data) { { 'reservation_id' => SecureRandom.uuid, 'start_date' => '2026-11-01' } }

  describe 'callbacks' do
    it 'sets event_type and action from the subclass on create' do
      event = event_class.create!(data:)

      expect(event.event_type).to eq(ReservationConstants::RESERVATION_CREATED)
      expect(event.action).to eq(ReservationConstants::CREATED_ACTION)
    end

    it 'stores the STI type so records load as their subclass' do
      event = event_class.create!(data:)

      expect(Event.find(event.id)).to be_a(event_class)
    end

    it 'enqueues EventBroadcastJob with the event id after commit' do
      event = event_class.create!(data:)

      expect(EventBroadcastJob.jobs.size).to eq(1)
      expect(EventBroadcastJob.jobs.first['args']).to eq([event.id])
    end

    it 'does not enqueue a broadcast when the transaction rolls back' do
      Event.transaction do
        event_class.create!(data:)
        raise ActiveRecord::Rollback
      end

      expect(EventBroadcastJob.jobs).to be_empty
    end
  end

  describe '#readonly?' do
    it 'is false for a new record' do
      expect(event_class.new(data:)).not_to be_readonly
    end

    it 'prevents updates once persisted' do
      event = event_class.create!(data:)

      expect { event.update!(source: 'admin') }.to raise_error(ActiveRecord::ReadOnlyRecord)
    end

    it 'prevents destroying once persisted' do
      event = event_class.create!(data:)

      expect { event.destroy }.to raise_error(ActiveRecord::ReadOnlyRecord)
    end
  end

  describe 'data (jsonb attribute)' do
    it 'round-trips a hash as a jsonb object' do
      event = event_class.create!(data:)

      expect(Event.find(event.id).data).to eq(data)
    end

    it 'parses a JSON string into a hash' do
      event = event_class.new(data: '{"reservation_id":"abc"}')

      expect(event.data).to eq('reservation_id' => 'abc')
    end

    it 'stores an object, not a JSON string scalar' do
      event = event_class.create!(data:)
      raw_type = Event.connection.select_value(
        Event.sanitize_sql(['SELECT jsonb_typeof(data) FROM events WHERE id = ?', event.id])
      )

      expect(raw_type).to eq('object')
    end

    it 'falls back to the default for invalid JSON' do
      expect(event_class.new(data: '{not json').data).to eq({})
    end

    it 'defaults to an empty hash' do
      expect(event_class.new.data).to eq({})
    end
  end
end
