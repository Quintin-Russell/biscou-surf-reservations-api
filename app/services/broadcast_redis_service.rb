# frozen_string_literal: true

class BroadcastRedisService
  def perform(event)
    $redis.with do |conn|
      conn.publish('events', Oj.dump(event))
      conn.xadd("event_stream", event)
    end
  end
end
