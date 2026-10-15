# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Events::EventData::ReservationData do
  let(:guest) { create(:user) }
  let(:manager) { create(:user) }
  let(:attrs) do
    {
      reservation_id: 'res-1',
      start_date: '2026-11-01',
      end_date: '2026-11-05',
      price: 500,
      primary_guest: guest.id,
      reservation_manager: manager.id,
      guests: [guest.id],
      accommodation: 'cabin-1'
    }
  end

  subject(:reservation_data) { described_class.new(attrs) }

  it 'is valid with complete attributes' do
    expect(reservation_data).to be_valid
  end

  it 'casts types and applies defaults' do
    expect(reservation_data.start_date).to eq(Date.new(2026, 11, 1))
    expect(reservation_data.paid).to be(false)
    expect(reservation_data.status).to eq(ReservationConstants::STATUS_PENDING)
    expect(reservation_data.activities).to eq([])
  end

  it 'is valid when paid is false' do
    expect(described_class.new(attrs.merge(paid: false))).to be_valid
  end

  %i[reservation_id price primary_guest reservation_manager accommodation start_date end_date].each do |field|
    it "requires #{field}" do
      record = described_class.new(attrs.merge(field => nil))

      expect(record).not_to be_valid
      expect(record.errors[field]).to include("can't be blank")
    end
  end

  it 'rejects an unparseable date' do
    record = described_class.new(attrs.merge(start_date: 'not a date'))

    expect(record).not_to be_valid
    expect(record.errors[:start_date]).to include("can't be blank")
  end

  it 'rejects a non-positive price' do
    record = described_class.new(attrs.merge(price: 0))

    expect(record).not_to be_valid
    expect(record.errors[:price]).to include('must be greater than 0')
  end

  it 'rejects an unknown status' do
    record = described_class.new(attrs.merge(status: 'archived'))

    expect(record).not_to be_valid
    expect(record.errors[:status]).to be_present
  end

  it 'rejects an end date on or before the start date' do
    record = described_class.new(attrs.merge(end_date: '2026-11-01'))

    expect(record).not_to be_valid
    expect(record.errors[:end_date]).to include('must be after start date')
  end

  it 'rejects a primary guest who is not a user' do
    missing_id = SecureRandom.uuid
    record = described_class.new(attrs.merge(primary_guest: missing_id, guests: [missing_id]))

    expect(record).not_to be_valid
    expect(record.errors[:primary_guest]).to include('does not exist')
  end

  it 'rejects a primary guest who is not in guests' do
    record = described_class.new(attrs.merge(guests: []))

    expect(record).not_to be_valid
    expect(record.errors[:primary_guest]).to include('must be one of the guests')
  end

  it 'rejects a reservation manager who is not a user' do
    record = described_class.new(attrs.merge(reservation_manager: SecureRandom.uuid))

    expect(record).not_to be_valid
    expect(record.errors[:reservation_manager]).to include('does not exist')
  end
end
