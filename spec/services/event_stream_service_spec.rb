# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventStreamService do
  let(:stream) { "test_event_stream_#{SecureRandom.hex(4)}" }
  let(:event) { instance_double(Event, id: 'evt-1', event_type: 'reservation.created') }

  before { allow(described_class).to receive(:publish).and_call_original }
  # own client: one example stubs $redis to fail
  after do
    redis = Redis.new(url: REDIS_CONFIG['url'])
    redis.del(stream)
    redis.close
  end

  describe '.publish' do
    it 'adds the event id and event type to the stream' do
      described_class.publish(event, stream:)

      entries = $redis.with { |conn| conn.xrange(stream) }
      expect(entries.map(&:last)).to eq([ { 'event_id' => event.id, 'event_type' => event.event_type } ])
    end

    it 'logs and does not raise when Redis fails' do
      allow($redis).to receive(:with).and_raise(Redis::CannotConnectError, 'connection refused')
      allow(Rails.logger).to receive(:error)

      expect(described_class.publish(event, stream:)).to be_nil
      expect(Rails.logger).to have_received(:error).with(/evt-1.*connection refused/)
    end
  end
end
