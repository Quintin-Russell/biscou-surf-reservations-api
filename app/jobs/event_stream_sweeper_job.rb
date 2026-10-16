# frozen_string_literal: true

# Re-publishes events the listener never marked processed: the XADD after commit
# failed, or the listener was down. Scheduled every 5 minutes in config/schedule.yml.
class EventStreamSweeperJob < BaseJob
  STALE_AFTER = 5.minutes

  def perform
    Event.where(processed_at: nil).where(created_at: ...STALE_AFTER.ago).find_each do |event|
      EventStreamService.publish(event)
    end
  end
end
