# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventListener do
  let(:redis) { Redis.new(url: REDIS_CONFIG['url']) }
  let(:stream) { "test_event_stream_#{SecureRandom.hex(4)}" }
  let(:group) { 'test_event_handlers' }
  let(:handler_job) { stub_const('TestHandlerJob', Class.new(BaseJob) { def perform(_event_id); end }) }
  let(:handlers) { { ReservationConstants::RESERVATION_CREATED => [ handler_job ] } }
  let(:listener) { described_class.new(redis:, stream:, group:, consumer: 'listener-1', handlers:) }
  let(:event) { Events::Reservations::ReservationCreatedEvent.create!(event_data: build(:reservation_data)) }

  before do
    stub_const('EventListener::BLOCK_MS', 10)
    listener.ensure_group
  end

  after do
    redis.del(stream)
    redis.close
  end

  def add_entry(event)
    redis.xadd(stream, { 'event_id' => event.id, 'event_type' => event.event_type })
  end

  def pending_count
    redis.xpending(stream, group)['size']
  end

  describe '#ensure_group' do
    it 'does not raise when the group already exists' do
      expect { listener.ensure_group }.not_to raise_error
    end
  end

  describe '#process_batch' do
    it 'enqueues each registered handler job with the event id' do
      add_entry(event)

      listener.process_batch

      expect(handler_job.jobs.map { |job| job['args'] }).to eq([ [ event.id ] ])
    end

    it 'acks the entry and marks the event processed' do
      add_entry(event)

      listener.process_batch

      expect(pending_count).to eq(0)
      expect(event.reload.processed_at).to be_present
    end

    it 'acks and marks processed an event type with no handlers' do
      add_entry(event)

      described_class.new(redis:, stream:, group:, consumer: 'listener-1', handlers: {}).process_batch

      expect(pending_count).to eq(0)
      expect(event.reload.processed_at).to be_present
    end

    it 'does not enqueue again for an event that is already processed' do
      event.mark_processed!
      add_entry(event)

      listener.process_batch

      expect(handler_job.jobs).to be_empty
      expect(pending_count).to eq(0)
    end

    it 'acks an entry whose event no longer exists' do
      redis.xadd(stream, { 'event_id' => SecureRandom.uuid, 'event_type' => ReservationConstants::RESERVATION_CREATED })

      listener.process_batch

      expect(pending_count).to eq(0)
      expect(handler_job.jobs).to be_empty
    end

    it 'leaves the entry pending and the event unprocessed when a handler fails to enqueue' do
      add_entry(event)
      allow(handler_job).to receive(:perform_async).and_raise(Redis::CannotConnectError)

      listener.process_batch

      expect(pending_count).to eq(1)
      expect(event.reload.processed_at).to be_nil
    end

    it 'reclaims an entry left unacked by another consumer' do
      stub_const('EventListener::RECLAIM_IDLE_MS', 0)
      add_entry(event)
      redis.xreadgroup(group, 'crashed-consumer', stream, '>')

      listener.process_batch

      expect(handler_job.jobs.map { |job| job['args'] }).to eq([ [ event.id ] ])
      expect(pending_count).to eq(0)
    end
  end

  describe '#run' do
    it 'exits after the current batch once stopped' do
      allow(listener).to receive(:process_batch) { listener.stop }
      allow(Signal).to receive(:trap)

      listener.run

      expect(listener).to have_received(:process_batch).once
    end
  end
end
