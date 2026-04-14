require Rails.root.join('app/constants/reservation_statuses_constants')
require Rails.root.join('app/constants/user_permissions_constants')
require Rails.root.join('app/constants/user_roles_constants')
require Rails.root.join('app/constants/accommodation_location_types_constants')
require Rails.root.join('app/constants/accommodation_types_constants')
require 'faker'

namespace :test_db do
  desc "Clears all data in the test database"
  task clear_test_database: :environment do
    exit unless confirm_before_continuing("This will clear ALL data in every table")

    User.destroy_all
    Event.destroy_all
    Accommodation.destroy_all
    AccommodationLocation.destroy_all
    Activity.destroy_all
  end

  ## populate users
  desc "Populates Users table w/ 10 random guests"
  task populate_guest_users: :environment do
    10.times do
      User.create!({
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        email: Faker::Internet.unique.email,
        password: "#{Faker::Lorem.word}#{rand(10..99)}!!",
        nationality: 'USA',
        phone_number: '441111111111',
        permission: UserPermissionsConstants::GUEST_PERMISSION,
        role: UserRolesConstants::GUEST_ROLE
      })
    end
  end

  desc "Populates Users table w/ 3 random employees of each permission level"
  task populate_employee_users: :environment do
    UserPermissionsConstants::EMPLOYEE_PERMISSIONS.each do |permission|
      3.times do
        User.create!({
         first_name: Faker::Name.first_name,
         last_name: Faker::Name.last_name,
         email: Faker::Internet.unique.email,
         password: "#{Faker::Lorem.word}#{rand(10..99)}!!",
         nationality: 'USA',
         phone_number: '441111111111',
         permission: permission,
         role: UserRolesConstants::EMPLOYEE_ROLE
        })
      end
    end
  end

  ## populate accommodation_locations
  desc "Populates 10 random accommodation locations"
  task populate_accommodation_locations: :environment do
    10.times do
      type = AccommodationLocationTypesConstants::ALL_TYPES.sample
      AccommodationLocation.create!({
        name: Faker::Superhero.name,
        location: Faker::Address.street_address,
        city: Faker::Address.city,
        property_type: type,
        capacity: rand(5..10)
      })
    end
  end

  ## populate accommodations
  desc "Populates 3 random accommodations for each type"
  task populate_accommodations: :environment do
    make_bed_accommodations
    make_room_accommodations
    make_whole_property_accommodations
  end

  private

  def make_bed_accommodations
    accommodation_location_id = AccommodationLocation.all.sample.id
    count = 1
    3.times do
      Accommodation.create({
       name: "dorm 1",
       accommodation_type: AccommodationTypesConstants::BED,
       bed_number: count,
       capacity: 1,
       accommodation_location_id: accommodation_location_id,
      })
    end
  end

  def make_room_accommodations
    disabled_accommodation_ids = Accommodation.where(name: 'dorm 1')
                                              .pluck(:accommodation_location_id)
                                              .uniq
    accommodation_location = select_valid_accommodation_location(disabled_accommodation_ids)
    accommodation_capacity = accommodation_location.capacity
    current_occupancy_count = 0
    3.times do
      room_capacity = rand(1..accommodation_capacity - current_occupancy_count)

      Accommodation.create({
        name: Faker::Beer.style,
        accommodation_type: AccommodationTypesConstants::ROOM,
        capacity: room_capacity,
        accommodation_location_id: accommodation_location.id,
      })

      current_occupancy_count += room_capacity

      if current_occupancy_count == accommodation_location.capacity
        disabled_accommodation_ids << accommodation_location.id
        select_valid_accommodation_location(disabled_accommodation_ids)
        current_occupancy_count = 0
      end
    end
  end

  def make_whole_property_accommodations
    disabled_accommodation_ids = Accommodation.select("WHERE name = 'dorm 1' OR accommodation_type = '#{AccommodationTypesConstants::ROOM}'")
                                              .pluck(:accommodation_location_id)
                                              .uniq
    3.times do
      accommodation_location = select_valid_accommodation_location(disabled_accommodation_ids)
      Accommodation.create({
        name: Faker::Book.genre,
        accommodation_type: AccommodationTypesConstants::WHOLE_PROPERTY,
        capacity: accommodation_location.capacity,
        accommodation_location_id: accommodation_location.id,
      })
      disabled_accommodation_ids << accommodation_location.id
    end
  end

  def select_valid_accommodation_location(invalid_accommodation_ids)
    AccommodationLocation.where
                         .not(id: invalid_accommodation_ids)
                         .first
  end

  def confirm_before_continuing(message)
    is_test = %w[development test].any?{ |env_val| env_val == Rails.env }
    unless is_test
      puts "NOT A TEST ENV! ABORTING!"
      exit
    end

    confirm_text = "Y"
    print "Are you sure? #{message}. if you want to continue, type #{confirm_text}. Anything else will cancel the job." + "\n"
    response = STDIN.gets.chomp

    response === confirm_text
  end
end