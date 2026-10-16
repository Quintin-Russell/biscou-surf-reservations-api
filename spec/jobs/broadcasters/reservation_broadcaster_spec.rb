# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Broadcasters::ReservationBroadcaster do
  let(:event) { Events::Reservations::ReservationCreatedEvent.create_event(event_data: build(:reservation_data)) }

  before { allow(BroadcastRedisService).to receive(:perform) }

  it 'is a BaseBroadcaster' do
    expect(described_class).to be < Broadcasters::BaseBroadcaster
  end

  describe '#perform' do
    it 'publishes the event payload to Redis' do
      described_class.new.perform(event)

      expect(BroadcastRedisService).to have_received(:perform).with(event.as_json)
    end

    it 'broadcasts the event payload to the events ActionCable stream' do
      expect { described_class.new.perform(event) }
        .to have_broadcasted_to('events').with(event.as_json)
    end
  end
end
