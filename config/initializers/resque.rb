# Resque configuration for ActiveJob integration
# This fixes the ActiveStorage threading deadlock issue in Rails 5.2

require 'resque'

# Configure Resque to use the existing Redis connection
# Redis is initialized in config/initializers/redis_config.rb
Resque.redis = $redis if $redis

# Set up Resque logger
Resque.logger = Logger.new(Rails.root.join('log', "resque_#{Rails.env}.log"))
Resque.logger.level = Logger::INFO

# Log Resque configuration on startup
Rails.application.config.after_initialize do
  if Resque.redis
    Rails.logger.info "Resque configured with Redis: #{Resque.redis.id}"
    Rails.logger.info "ActiveJob queue adapter: #{Rails.application.config.active_job.queue_adapter}"
  else
    Rails.logger.error "Resque: Redis connection not available"
  end
end
