FactoryBot.define do
  factory :event do
    # reservation
    trait :reservation_created do
      event_type { 'reservation.created' }
      action { 'created' }
    end

    trait :reservation_canceled do
      event_type { 'reservation.update' }
      action { 'canceled' }
    end

    trait :reservation_checkin do
      event_type { 'reservation.update' }
      action { 'checkin' }
    end

    trait :reservation_checkout do
      event_type { 'reservation.update' }
      action { 'checkout' }
    end

    trait :reservation_guest_change do
      event_type { 'reservation.update' }
      action { 'guest_change' }
      end

    trait :reservation_activity_change do
      event_type { 'reservation.update' }
      action { 'activity_change' }
      end

    trait :reservation_admin_change do
      event_type { 'reservation.update' }
      action { 'admin_change' }
      end

    trait :reservation_accommodation_change do
      event_type { 'reservation.update' }
      action { 'accommodation_change' }
    end
    ## put traits that control amount of guests and activities

    # user
    trait :user_created do
      event_type { 'user.created' }
      action { 'created' }
    end

    # activity
    trait :activity_created do
      event_type { 'activity.created' }
      action { 'created' }
    end
  end
end