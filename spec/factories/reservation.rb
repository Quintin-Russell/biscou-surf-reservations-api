FactoryBot.define do
  factory :reservation do
    start_date
    end_date
    base_price
    discount

    association :accommodation
    association :guests, factory: :user
    association :primary_guest, factory: :user
    association :reservation_manager, factory: :user
    association :activities, factory: :activity

    ## Accommodation traits
    trait :accommodation_room do
      accommodation { build(:accommodation, :room) }
    end

    trait :accommodation_entire do
      accommodation { build(:accommodation, :entire_accommodation) }
    end

    trait :accommodation_bed do
      accommodation { build(:accommodation, :bed) }
    end

    ## Activities traits
    trait :with_activities do
      activities { Array.new(rand(1..5)) { build(:activity) } }
    end

    ## Guest traits
    trait :single_guest do
      guests { [build(:user, :guest)] }
      primary_guest { guests[0] }
    end

    trait :many_guests do
      guests { Array.new(rand(1..5)) { build(:user, :guest) } }
      primary_guest { guests[0] }
    end
  end
end