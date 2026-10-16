# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event do
  let(:event_class) { Events::Reservations::ReservationCreatedEvent }
  let(:event_data) { build(:reservation_data) }

  describe 'callbacks' do
    it 'sets event_type and action from the subclass on create' do
      event = event_class.create!(event_data:)

      expect(event.event_type).to eq(ReservationConstants::RESERVATION_CREATED)
      expect(event.action).to eq(ReservationConstants::CREATED_ACTION)
    end

    it 'stores the STI type so records load as their subclass' do
      event = event_class.create!(event_data:)

      expect(Event.find(event.id)).to be_a(event_class)
    end

    it 'enqueues EventBroadcastJob with the event id after commit' do
      event = event_class.create!(event_data:)

      expect(EventBroadcastJob.jobs.size).to eq(1)
      expect(EventBroadcastJob.jobs.first['args']).to eq([event.id])
    end

    it 'does not enqueue a broadcast when the transaction rolls back' do
      Event.transaction do
        event_class.create!(event_data:)
        raise ActiveRecord::Rollback
      end

      expect(EventBroadcastJob.jobs).to be_empty
    end
  end

  describe '#readonly?' do
    it 'is false for a new record' do
      expect(event_class.new(event_data:)).not_to be_readonly
    end

    it 'prevents updates once persisted' do
      event = event_class.create!(event_data:)

      expect { event.update!(source: 'admin') }.to raise_error(ActiveRecord::ReadOnlyRecord)
    end

    it 'prevents destroying once persisted' do
      event = event_class.create!(event_data:)

      expect { event.destroy }.to raise_error(ActiveRecord::ReadOnlyRecord)
    end
  end

  describe '#mark_processed!' do
    let(:event) { event_class.create!(event_data:) }

    it 'sets processed_at and returns true' do
      freeze_time do
        expect(event.mark_processed!).to be(true)
        expect(event.processed_at).to eq(Time.current)
        expect(Event.find(event.id).processed_at).to eq(Time.current)
      end
    end

    it 'returns false and keeps the original time when already processed' do
      event.mark_processed!
      first = event.processed_at

      travel 1.minute do
        expect(event.mark_processed!).to be(false)
        expect(event.processed_at).to eq(first)
      end
    end

    it 'only lets one of two copies of the same event claim it' do
      copy = Event.find(event.id)

      expect(event.mark_processed!).to be(true)
      expect(copy.mark_processed!).to be(false)
    end

    it 'does not write other changed attributes' do
      event.source = 'admin'
      event.mark_processed!

      expect(Event.find(event.id).source).to eq('api')
    end

    it 'raises for an unsaved event' do
      expect { event_class.new(event_data:).mark_processed! }
        .to raise_error(ActiveRecord::RecordNotSaved, /unsaved event/)
    end

    it 'stays readonly after being processed' do
      event.mark_processed!

      expect { event.update!(source: 'admin') }.to raise_error(ActiveRecord::ReadOnlyRecord)
    end
  end

  describe 'data (jsonb attribute)' do
    it 'round-trips the payload attributes as a jsonb object' do
      event = event_class.create!(event_data:)

      expect(Event.find(event.id).data).to eq(event_data.attributes.as_json)
    end

    it 'parses a JSON string into a hash' do
      event = event_class.new(data: '{"reservation_id":"abc"}')

      expect(event.data).to eq('reservation_id' => 'abc')
    end

    it 'stores an object, not a JSON string scalar' do
      event = event_class.create!(event_data:)
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

  describe 'event_data' do
    it "accepts the event's data_class and stores its attributes in data" do
      user_created_data = build(:user_created_data)
      event = Events::Users::UserCreatedEvent.create!(event_data: user_created_data)

      expect(event.reload.data).to eq(user_created_data.attributes.as_json)
    end

    it 'rejects a payload that is not a BaseEventData' do
      expect { event_class.new(event_data: { 'reservation_id' => 'res-1' }) }
        .to raise_error(ArgumentError, /must match the expected data class/)
    end

    it "rejects a BaseEventData that is not the event's data_class" do
      expect { event_class.new(event_data: build(:user_created_data)) }
        .to raise_error(ArgumentError, /must match the expected data class/)
    end

    it 'raises when the event class does not declare a data_class' do
      expect { Event.new(event_data: build(:reservation_data)) }
        .to raise_error(NotImplementedError)
    end

    it 'is required on create' do
      event = event_class.new(data: { 'reservation_id' => 'res-1' })

      expect(event).not_to be_valid
      expect(event.errors[:event_data]).to include("can't be blank")
    end

    it 'adds payload validation errors to the event' do
      event = event_class.new(event_data: build(:reservation_data, price: nil))

      expect(event).not_to be_valid
      expect(event.errors[:event_data]).to include("price can't be blank")
    end

    it 'is not set on events loaded from the database' do
      event = event_class.create!(event_data:)

      expect(Event.find(event.id).event_data).to be_nil
    end
  end
end
