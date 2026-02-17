# frozen_string_literal: true

## All listeners need a #process_action method so that #start works as desired
  class BaseListener
    attr_reader :redis, :thread

    # require_relative 'action_handlers/reservation_action_handler'
    # require_relative 'action_handlers/user_action_handler'
    # require_relative 'action_handlers/activity_action_handler'
    def initialize(redis: nil)
      @redis = redis || Redis.new
      @thread = nil
    end

    def start
      return if @thread&.alive?

      @thread = Thread.new do
        @redis.subscribe("events") do |on|
          on.message do |_channel, _msg|
            event = Oj.load(message)
            process_message(event)
          end
        end
      end
    end

    def stop
      @thread&.kill
      @thread = nil
    end

    def process_message(event)
      action = event["action"]

      case event.event_type
      when /^reservation\./
        ReservationActionHandler.process_action(action)
      when /^user\./
        UserActionHandler.process_action(action)
      when /^activity\./
        ActivityActionHandler.process_action(action)
      else
        Rails.logger.warn "#{event.event_type} not broadcasted"
      end
    end
  end