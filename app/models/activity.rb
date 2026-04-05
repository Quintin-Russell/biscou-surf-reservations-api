class Activity < ApplicationRecord
  attribute :name, type: String
  attribute :description, type: String
  attribute :availability_start, type: DateTime
  attribute :availability_end, type: DateTime
  attribute :standard_cost, type: Integer
end
