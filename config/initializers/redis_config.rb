redis_config = Rails.application.config_for(:redis)

# if $redis
#   begin
#     Rails.logger.info "Redis connection status: #{$redis.ping}"
#   rescue Redis::CannotConnectError
#     Rails.logger.error "Cannot connect to Redis"
#   end
# else
#   Rails.logger.error "Redis is not configured"
#
#   raise "Redis is required in #{Rails.env} environment." if Rails.env.production?
# end

$redis = begin
           redis = Redis.new(
             host: redis_config[:host],
             port: redis_config[:port],
             thread_safe: true,
             timeout: 5
           )

           redis.ping
           Rails.logger.info "Redis connection established."
           redis

         rescue Redis::CannotConnectError => e
           Rails.logger.error "Cannot connect to Redis: #{e.message}"
           Rails.env.production? ? raise : nil
         end

Nest.class_eval do
  def initialize(key, redis=$redis)
    super(key.to_param)
    @redis = redis
  end

  def [](key)
    self.class.new("#{self}:#{key.to_param}", @redis)
  end
end

if $redis
  TapasRails::Application::Queue = TapasRails::Resque::Queue.new('tapas_rails')
else
  Rails.logger.warn "Queue not initialized. Redis is unavailable."
end
