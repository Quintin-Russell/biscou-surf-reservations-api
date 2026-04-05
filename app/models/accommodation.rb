class Accommodation < ApplicationRecord
  attribute :name, type: String
  attribute :type, type: String
  attribute :bed_number, type: Integer
  attribute :capacity, type: Integer

  belongs_to :accommodation_location
end
