class Event < ApplicationRecord
  include JsonbAttribute

  attribute :processed_at, type: DateTime
  attribute :event_type, type: String
  attribute :source, type: String
  attribute :action, type: String

  jsonb_attribute :data

  ## getters: search payload for
  # reservation id
  # guest names
  # accommodation
end
