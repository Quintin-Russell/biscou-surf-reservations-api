# frozen_string_literal: true
REDIS_CONFIG = YAML.load_file(Rails.root.join('config/redis.yml'))[Rails.env]

# Sidekiq configuration
Sidekiq.configure_server do |config|
  config.redis = { url: REDIS_CONFIG['url'], size: REDIS_CONFIG['size'] }

  # Add middleware for error handling
  config.server_middleware do |chain|
    chain.add Sidekiq::Middleware::Server::RetryJobs, max_retries: 3
  end

  # Schedule recurring jobs
  schedule_file = Rails.root.join('config/schedule.yml')
  if File.exist?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: REDIS_CONFIG['url'], size: 1 }
end
