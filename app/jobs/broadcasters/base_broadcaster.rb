# frozen_string_literal: true

class BaseBroadcaster
  def broadcast(event)
    # broadcast to Redis
    BroadcastRedisService.perform(event)
    # broadcast to FE (ActionCable)
    EventChannel.broadcast_to_frontend(event)
  end
end