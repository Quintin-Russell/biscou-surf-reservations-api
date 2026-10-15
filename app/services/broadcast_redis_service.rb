# frozen_string_literal: true

class BroadcastRedisService
  def self.perform(payload)
    json = Oj.dump(payload, mode: :compat)
    $redis.with do |conn|
      conn.publish('events', json)
      # stream entries are flat field/value string pairs
      conn.xadd("event_stream", { "event" => json })
    end
  end
end
