# frozen_string_literal: true

# Delivery channel for committed events. Postgres stays the permanent log; the
# stream only carries the event id so consumers reload the event from the DB.
class EventStreamService
  STREAM = "event_stream"
  GROUP = "event_handlers"
  MAX_LENGTH = 100_000

  class << self
    # never raises: the event is already committed, and EventStreamSweeperJob
    # re-publishes anything that was not processed
    def publish(event, stream: STREAM)
      $redis.with do |conn|
        # stream entries are flat field/value string pairs
        conn.xadd(stream, { "event_id" => event.id, "event_type" => event.event_type },
                  approximate: true, maxlen: MAX_LENGTH)
      end
    rescue Redis::BaseError => e
      Rails.logger.error "EventStreamService failed to publish event #{event.id}: #{e.message}"
      nil
    end
  end
end
