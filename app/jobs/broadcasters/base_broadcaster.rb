# frozen_string_literal: true

module Broadcasters
  class BaseBroadcaster
    def broadcast(event)
      payload = event.as_json
      # broadcast to Redis
      BroadcastRedisService.perform(payload)
      # broadcast to FE (ActionCable)
      EventChannel.broadcast_to_frontend(payload)
    end
  end
end
