# frozen_string_literal: true

require "socket"

class EventListener
  HANDLERS = {
    # left empty but will eventually contain key:value pairs of event_type: array of sidekiq jobs
    # EX) 'user.created': [Users::SendWelcomeEmail, Users::BroadcastToFrontendJob]
  }.freeze

  BATCH_SIZE = 10
  BLOCK_MS = 5_000
  RECLAIM_IDLE_MS = 60_000

  attr_reader :redis, :stream, :group, :consumer, :handlers

  def initialize(redis: Redis.new(url: REDIS_CONFIG["url"]),
                 stream: EventStreamService::STREAM,
                 group: EventStreamService::GROUP,
                 consumer: "#{Socket.gethostname}-#{Process.pid}",
                 handlers: HANDLERS)
    @redis = redis
    @stream = stream
    @group = group
    @consumer = consumer
    @handlers = handlers
    @stopping = false
  end

  def run
    trap_signals
    ensure_group
    Rails.logger.info "EventListener #{consumer} reading #{stream} as #{group}"
    process_batch until @stopping
  ensure
    redis.close
  end

  def stop
    @stopping = true
  end

  def ensure_group
    redis.xgroup(:create, stream, group, "0", mkstream: true)
  rescue Redis::CommandError => e
    raise unless e.message.include?("BUSYGROUP")
  end

  def process_batch
    reclaim_stale
    read_new
  end

  def reclaim_stale
    result = redis.xautoclaim(stream, group, consumer, RECLAIM_IDLE_MS, "0-0", count: BATCH_SIZE)
    handle_entries(result["entries"])
  end

  def read_new
    result = redis.xreadgroup(group, consumer, stream, ">", count: BATCH_SIZE, block: BLOCK_MS)
    handle_entries(result.fetch(stream, []))
  end

  def handle(entry_id, fields)
    event = Event.find_by(id: fields["event_id"])

    if event.nil?
      Rails.logger.warn "EventListener: event #{fields['event_id']} not found, acking entry #{entry_id}"
    elsif event.processed_at.nil?
      handlers.fetch(event.event_type, []).each { |job| job.perform_async(event.id) }
      event.mark_processed!
    end

    redis.xack(stream, group, entry_id)
  rescue StandardError => e
    Rails.logger.error "EventListener failed on entry #{entry_id}: #{e.class}: #{e.message}"
  end

  private

  def handle_entries(entries)
    return if entries.blank?

    Rails.application.executor.wrap do
      entries.each { |entry_id, fields| handle(entry_id, fields) }
    end
  end

  # finishes the current batch (at most BLOCK_MS of waiting) and exits
  def trap_signals
    %w[TERM INT].each { |signal| Signal.trap(signal) { stop } }
  end
end
