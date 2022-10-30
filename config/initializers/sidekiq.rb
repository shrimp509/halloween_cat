Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://redis:5432' }
end
