class AccommodationLocation < ApplicationRecord
  attribute :name, type: String
  attribute :location, type: String
  attribute :city, type: String
  attribute :property_type, type: String
  attribute :capacity, type: Integer

  has_many :accommodations, foreign_key: :accommodation_location_id
end
