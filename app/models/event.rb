class Event < ApplicationRecord
  before_create :set_event_type, :set_action

  include JsonbAttribute

  attribute :processed_at, type: DateTime
  attribute :event_type, type: String
  attribute :source, type: String, default: "api"
  attribute :action, type: String

  jsonb_attribute :data

  # the typed payload this event was created with; only set on new records,
  # loaded events expose the stored hash through #data
  attr_reader :event_data

  validates :event_data, presence: true, on: :create
  validate :event_data_valid, on: :create, if: :event_data

  after_create_commit :enqueue_broadcast

  def self.data_class
    raise NotImplementedError, "Event must declare a data_class"
  end
  def self.create_event(event_data:)
    create!(event_data:)
  end

  def event_data=(payload)
    unless payload.is_a?(self.class.data_class)
      raise ArgumentError, "#{self.class.name} event_data must match the expected data class"
    end

    @event_data = payload
    self.data = payload.attributes
  end

  # events are append-only: once persisted they cannot be updated or destroyed.
  # the one exception is processed_at, written only through #mark_processed!
  def readonly?
    persisted? || super
  end

  # sets processed_at once, atomically. returns true only for the call that set it,
  # so duplicate deliveries of the same event can't both claim it
  def mark_processed!
    raise ActiveRecord::RecordNotSaved.new("cannot mark an unsaved event as processed", self) if new_record?

    now = Time.current
    claimed = Event.where(id:, processed_at: nil).update_all(processed_at: now, updated_at: now).positive?
    reload
    claimed
  end

  def set_event_type
    self.event_type = self.class.event_type
  end

  def set_action
    self.action = self.class.action
  end

  private

  def event_data_valid
    return if event_data.valid?

    event_data.errors.each { |error| errors.add(:event_data, "#{error.attribute} #{error.message}") }
  end

  # runs only after the transaction commits, so workers never see an uncommitted event
  def enqueue_broadcast
    EventBroadcastJob.perform_async(id)
  end
end
