# frozen_string_literal: true

class EventStreamService
  STREAM = "event_stream"
  GROUP = "event_handlers"
  MAX_LENGTH = 100_000

  class << self
    def publish(event, stream: STREAM)
      $redis.with do |conn|
        conn.xadd(stream, { "event_id" => event.id, "event_type" => event.event_type },
                  approximate: true, maxlen: MAX_LENGTH)
      end
    rescue Redis::BaseError => e
      Rails.logger.error "EventStreamService failed to publish event #{event.id}: #{e.message}"
      nil
    end
  end
end
