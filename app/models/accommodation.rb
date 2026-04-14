class Accommodation < ApplicationRecord
  attribute :name, type: String
  attribute :accommodation_type, type: String
  attribute :bed_number, type: Integer
  attribute :capacity, type: Integer
  attribute :accommodation_location_id, type: :uuid

  belongs_to :accommodation_location
end
