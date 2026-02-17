# frozen_string_literal: true

class ReservationBroadcaster < BaseBroadcaster
  def perform(event)
    broadcast(event)
    # after action/cleanup
  end
end