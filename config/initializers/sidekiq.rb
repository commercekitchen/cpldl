# frozen_string_literal: true

redis_url =
  if ENV["REDIS_HOST"].present?
    "redis://#{ENV["REDIS_HOST"]}:#{ENV["REDIS_PORT"].presence || 6379}/0"
  else
    Rails.application.credentials.dig(Rails.env.to_sym, :redis, :url)
  end

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end