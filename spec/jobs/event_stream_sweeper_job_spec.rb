# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventStreamSweeperJob do
  def create_event(created_at:, processed: false)
    event = travel_to(created_at) do
      Events::Reservations::ReservationCreatedEvent.create!(event_data: build(:reservation_data))
    end
    event.mark_processed! if processed
    event
  end

  describe '#perform' do
    it 're-publishes only unprocessed events older than 5 minutes' do
      stale = create_event(created_at: 6.minutes.ago)
      create_event(created_at: 6.minutes.ago, processed: true)
      create_event(created_at: 1.minute.ago)
      published = []
      allow(EventStreamService).to receive(:publish) { |event| published << event }

      described_class.new.perform

      expect(published).to eq([ stale ])
    end
  end
end
