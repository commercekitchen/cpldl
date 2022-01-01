# frozen_string_literal: true

sidekiq_config = { url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}/12" }

Sidekiq.configure_server do |config|
  config.redis = sidekiq_config
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_config
end