# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventBroadcastJob do
  let(:event) { Events::Reservations::ReservationCreatedEvent.create_event(event_data: build(:reservation_data)) }

  it 'uses the events queue with 3 retries' do
    expect(described_class.get_sidekiq_options).to include('queue' => :events, 'retry' => 3)
  end

  it 'routes reservation events to the reservation broadcaster' do
    broadcaster = instance_double(Broadcasters::ReservationBroadcaster)
    allow(Broadcasters::ReservationBroadcaster).to receive(:new).and_return(broadcaster)
    expect(broadcaster).to receive(:perform).with(event)

    described_class.new.perform(event.id)
  end

  it 'logs and skips events with no broadcaster' do
    allow(Event).to receive(:find).with('evt-1').and_return(instance_double(Event, event_type: 'user.created'))
    expect(Broadcasters::ReservationBroadcaster).not_to receive(:new)
    expect(Rails.logger).to receive(:warn).with('user.created not broadcasted')

    described_class.new.perform('evt-1')
  end

  it 'raises when the event does not exist so Sidekiq retries' do
    expect { described_class.new.perform(SecureRandom.uuid) }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
