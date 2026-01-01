# frozen_string_literal: true

# Configure Redis connection
REDIS_CONFIG = YAML.load_file(Rails.root.join('config/redis.yml'))[Rails.env]

# Global Redis connection for events
$redis = ConnectionPool.new(size: REDIS_CONFIG['size'], timeout: REDIS_CONFIG['pool_timeout']) do
  Redis.new(url: REDIS_CONFIG['url'])
end

# Quick health check
begin
  $redis.with { |conn| conn.ping }
  Rails.logger.info "✅ Redis connected successfully"
rescue => e
  Rails.logger.error "❌ Redis connection failed: #{e.message}"
end

