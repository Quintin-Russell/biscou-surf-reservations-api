FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    phone_number { Faker::PhoneNumber.cell_phone_in_e164 }
    nationality { Faker::Address.country }
    email { Faker::Internet.email }
    # role
    # permission
  end
#    add traits: admin, guest, employee
#    permissions: admin, manager, employee, guest, primary_guest
  trait :admin do
    role { 'employee' }
    permission { '' }
  end

  trait :employee do
    role { 'employee' }
    permission { 'employee' }
  end

  trait :guest do
    role { 'guest' }
    permission { 'guest' }
  end

  trait :primary_guest_permission do
    permission { 'primary_guest' }
  end

  trait :admin_permission do
    permission { 'admin' }
  end

  trait :manager_permission do
    permission { 'manager' }
  end
end