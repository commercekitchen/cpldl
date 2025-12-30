# frozen_string_literal: true

redis_url = "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT'] || 6379}/0"

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end