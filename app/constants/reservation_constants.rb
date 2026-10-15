module ReservationConstants
  ## reservation statuses
  STATUS_CONFIRMED = 'confirmed'
  STATUS_CHECKED_IN = 'checked_in'
  STATUS_CHECKED_OUT = 'checked_out'
  STATUS_CANCELLED = 'cancelled'
  STATUS_NO_SHOW = 'no_show'
  STATUS_PENDING = 'pending'

  ALL_STATUSES = [
    STATUS_PENDING,
    STATUS_CONFIRMED,
    STATUS_CHECKED_IN,
    STATUS_CHECKED_OUT,
    STATUS_CANCELLED,
    STATUS_NO_SHOW
  ].freeze

  ACTIVE_STATUSES = [
    STATUS_CONFIRMED,
    STATUS_CHECKED_IN
  ].freeze

  INACTIVE_STATUSES = [
    STATUS_CANCELLED,
    STATUS_NO_SHOW,
    STATUS_CHECKED_OUT
  ].freeze

  GOOD_STANDING_STATUSES = [
    STATUS_CONFIRMED,
    STATUS_CHECKED_IN,
    STATUS_CHECKED_OUT
  ].freeze

  BAD_STANDING_STATUSES = [
    STATUS_NO_SHOW,
    STATUS_CANCELLED,
    STATUS_PENDING
  ].freeze

  ## regex for event type identification
  RESERVATION_EVENT_REGEX = /\Areservation\./
  USER_EVENT_REGEX = /\Auser\./
  ACTIVITY_EVENT_REGEX = /\Aactivity\./

  ## event types
  RESERVATION_CREATED = 'reservation.created'
  RESERVATION_UPDATE = 'reservation.update'
  ## ACTION
  CREATED_ACTION = 'created'
  ACCOMMODATION_UPDATE_ACTION = 'accommodation_change'
  ADMIN_CHANGE_ACTION = 'admin_change'
  CANCELED_ACTION = 'canceled'
  CHECKIN_ACTION = 'checkin'
  CHECKOUT_ACTION = 'checkout'
  GUEST_ADDED_ACTION = 'guest_added'
  GUEST_REMOVED_ACTION = 'guest_removed'
  ## reservation event creation
  RESERVATION_EVENT_CREATOR_BY_ACTION = {

  }
end