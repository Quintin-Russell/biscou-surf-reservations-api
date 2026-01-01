# frozen_string_literal: true

class EventStorageJob < BaseJob
  def perform(event)
    Event.create!(event)
  end
end
