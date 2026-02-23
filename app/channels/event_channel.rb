# frozen_string_literal: true
class EventChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'events'
  end

  def broadcast_to_frontend(event)
    ActionCable.server.broadcast("events", event)
  end

  def unsubscribed
    # Clean up when frontend disconnects
    Rails.logger.info "📡 Frontend unsubscribed from events"
  end
end