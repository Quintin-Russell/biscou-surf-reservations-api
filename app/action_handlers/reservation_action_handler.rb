# frozen_string_literal: true

class ReservationActionHandler
  def self.process_action(action)
    raise Exceptions::MissingEventParametersError("cannot process event without an action") unless action.present?

    case action
    when "created"
      handle_reservation_created
    when "guest_change"
      handle_reservation_guest_change
    when "activity_change"
      handle_reservation_activity_change
    when "admin_change"
      handle_reservation_admin_change
    when "accommodation_change"
      handle_reservation_accommodation_change
    when "checkin"
      handle_reservation_checkin
    when "checkout"
      handle_reservation_checkout
    when "canceled"
      handle_reservation_canceled
    else
      raise Exceptions::UnbroadcastableEvent
    end
  end

  private

  def self.handle_reservation_created
    puts "reservation event created"
  end

  def self.handle_reservation_guest_change
    puts "reservation event guest change"
  end

  def self.handle_reservation_activity_change
    puts "reservation event activity change"
  end

  def self.handle_reservation_admin_change
    puts "reservation event admin change"
  end

  def self.handle_reservation_accommodation_change
    puts "reservation event accommodation change"
  end

  def self.handle_reservation_checkin
    puts "reservation check in"
  end

  def self.handle_reservation_checkout
    puts "reservation checkout process"
  end

  def self.handle_reservation_canceled
    puts "reservation canceled process"
  end
end