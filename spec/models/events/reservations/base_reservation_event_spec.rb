# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Events::Reservations::BaseReservationEvent do
  describe 'subclass event types and actions' do
    {
      Events::Reservations::ReservationCreatedEvent => [ReservationConstants::RESERVATION_CREATED, ReservationConstants::CREATED_ACTION],
      Events::Reservations::ReservationCancelEvent => [ReservationConstants::RESERVATION_UPDATE, ReservationConstants::CANCELED_ACTION],
      Events::Reservations::ReservationCheckinEvent => [ReservationConstants::RESERVATION_UPDATE, ReservationConstants::CHECKIN_ACTION],
      Events::Reservations::ReservationCheckoutEvent => [ReservationConstants::RESERVATION_UPDATE, ReservationConstants::CHECKOUT_ACTION],
      Events::Reservations::ReservationGuestAddedEvent => [ReservationConstants::RESERVATION_UPDATE, ReservationConstants::GUEST_ADDED_ACTION],
      Events::Reservations::ReservationGuestRemovedEvent => [ReservationConstants::RESERVATION_UPDATE, ReservationConstants::GUEST_REMOVED_ACTION],
      Events::Reservations::ReservationAdminChangeEvent => [ReservationConstants::RESERVATION_UPDATE, ReservationConstants::ADMIN_CHANGE_ACTION],
      Events::Reservations::ReservationAccommodationChangeEvent => [ReservationConstants::RESERVATION_UPDATE, ReservationConstants::ACCOMMODATION_UPDATE_ACTION]
    }.each do |klass, (event_type, action)|
      it "#{klass.name.demodulize} is #{event_type} / #{action}" do
        expect(klass.event_type).to eq(event_type)
        expect(klass.action).to eq(action)
      end
    end
  end

  describe '.create_event' do
    let(:event_class) { Events::Reservations::ReservationCheckinEvent }

    let(:reservation_data) { build(:reservation_data, reservation_id: 'res-1') }

    it 'persists the event with type, action and the payload attributes' do
      event = event_class.create_event(event_data: reservation_data)

      expect(event).to be_persisted
      expect(event.event_type).to eq(ReservationConstants::RESERVATION_UPDATE)
      expect(event.action).to eq(ReservationConstants::CHECKIN_ACTION)
      expect(event.reload.data).to eq(reservation_data.attributes.as_json)
    end

    it 'leaves processed_at unset until the event is delivered' do
      expect(event_class.create_event(event_data: reservation_data).processed_at).to be_nil
    end
  end

  describe 'scopes' do
    let(:event_class) { Events::Reservations::ReservationCreatedEvent }
    let!(:match) do
      event_class.create_event(event_data: build(:reservation_data, reservation_id: 'res-1', start_date: Date.new(2026, 11, 1)))
    end
    let!(:other) do
      event_class.create_event(event_data: build(:reservation_data, reservation_id: 'res-2', start_date: Date.new(2026, 12, 1)))
    end

    it '.by_id finds events by data reservation_id' do
      expect(described_class.by_id('res-1')).to contain_exactly(match)
    end

    it '.by_start_date finds events by data start_date' do
      expect(described_class.by_start_date(Date.new(2026, 11, 1))).to contain_exactly(match)
    end

    it '.by_start_date accepts a date string' do
      expect(described_class.by_start_date('2026-12-01')).to contain_exactly(other)
    end
  end
end
