module Events
  module Reservations
    class BaseReservationEvent < Event
      ## scopes
      scope :by_id, -> (reservation_id) { where("reservation_id = ?", reservation_id) }
      scope :by_start_date, -> (start_date) { where("start_date = ?", start_date) }
      ## methods
    end
  end
end