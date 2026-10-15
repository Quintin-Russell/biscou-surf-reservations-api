# frozen_string_literal: true

module Broadcasters
  class ReservationBroadcaster < BaseBroadcaster
    def perform(event)
      broadcast(event)
      # after action/cleanup
    end
  end
end
