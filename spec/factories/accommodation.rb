FactoryBot.define do
  factory :accommodation do
    name { Faker::Lorem.word }
    # type { [ 'entire_accommodation', 'room', 'bed' ].sample }
    # bed_number
    # capacity
    trait :entire_accommodation do
      type { 'entire_accommodation' }
      capacity { rand(4..8) }
    end

    trait :room do
      type { 'room' }
      capacity { rand(2..4) }
    end

    trait :bed do
      type { 'bed' }
      bed_number { rand(1..5) }
    end
  end
end