class Event < ApplicationRecord
  before_create :set_event_type, :set_action

  include JsonbAttribute

  attribute :processed_at, type: DateTime
  attribute :event_type, type: String
  attribute :source, type: String, default: 'api'
  attribute :action, type: String

  jsonb_attribute :data

  after_create_commit :enqueue_broadcast

  # events are append-only: once persisted they cannot be updated or destroyed
  def readonly?
    persisted? || super
  end

  ## getters: search payload for
  # reservation id
  # guest names
  # accommodation

  def set_event_type
    self.event_type = self.class.event_type
  end
  def set_action
    self.action = self.class.action
  end

  private

  # runs only after the transaction commits, so workers never see an uncommitted event
  def enqueue_broadcast
    EventBroadcastJob.perform_async(id)
  end
end
