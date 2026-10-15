# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BroadcastRedisService do
  let(:conn) { instance_double(Redis, publish: 1, xadd: '1-0') }
  let(:payload) { { 'id' => 'evt-1', 'event_type' => 'reservation.created', 'data' => { 'reservation_id' => 'res-1' } } }
  let(:json) { Oj.dump(payload, mode: :compat) }

  before { allow($redis).to receive(:with).and_yield(conn) }

  describe '.perform' do
    it 'publishes the JSON payload on the events channel' do
      described_class.perform(payload)

      expect(conn).to have_received(:publish).with('events', json)
    end

    it 'appends the JSON payload to the event stream as a single field' do
      described_class.perform(payload)

      expect(conn).to have_received(:xadd).with('event_stream', { 'event' => json })
    end
  end
end
