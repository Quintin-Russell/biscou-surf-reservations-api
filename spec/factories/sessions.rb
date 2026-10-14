FactoryBot.define do
  factory :session do
    user
    ip_address { Faker::Internet.ip_v4_address }
    expires_at { AuthenticationConstants::AUTH_DURATION.from_now }

    trait :expired do
      expires_at { 1.minute.ago }
    end
  end
end
