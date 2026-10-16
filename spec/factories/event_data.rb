FactoryBot.define do
  # event payloads are ActiveModel objects, not records
  factory :reservation_data, class: 'Events::EventData::ReservationData' do
    skip_create
    initialize_with { new(attributes) }

    transient do
      guest { create(:user) }
      manager { create(:user) }
    end

    reservation_id { SecureRandom.uuid }
    start_date { Date.new(2026, 11, 1) }
    end_date { start_date + 4 }
    price { 500 }
    primary_guest { guest.id }
    reservation_manager { manager.id }
    guests { [guest.id] }
    accommodation { 'cabin-1' }
  end

  factory :user_created_data, class: 'Events::EventData::UserCreatedData' do
    skip_create
    initialize_with { new(attributes) }

    user_id { create(:user).id }
    created_by { create(:user).id }
  end
end
