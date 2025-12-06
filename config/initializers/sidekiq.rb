# frozen_string_literal: true

redis_url = Rails.application.credentials.dig(:redis, :url)

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end