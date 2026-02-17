FactoryBot.define do
  factory :activity do
    transient do
      name { Faker::Hobby.activity }
      description { Faker::Lorem.paragraph }
      availability_start { Date.today + 2.weeks }
      availability_end { Date.today + 8.weeks }
      standard_cost { rand(20..100) }
    end
  end
end