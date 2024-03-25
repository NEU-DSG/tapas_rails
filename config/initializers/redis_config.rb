config = YAML::load(ERB.new(IO.read(File.join(Rails.root, 'config', 'redis.yml'))).result)[Rails.env].with_indifferent_access
$redis = Redis.new(host: config[:host], port: config[:port], thread_safe: true) rescue nil

if $redis
  begin
    Rails.logger.info "Redis connection status: #{$redis.ping}"
  rescue Redis::CannotConnectError
    Rails.logger.error "Cannot connect to Redis"
  end
else
  Rails.logger.error "Redis is not configured"
end

# $redis.client.reconnect

# Code borrowed from Obie's Redis patterns talk at RailsConf'12
Nest.class_eval do
  def initialize(key, redis=$redis)
    super(key.to_param)
    @redis = redis
  end

  def [](key)
    self.class.new("#{self}:#{key.to_param}", @redis)
  end
end

TapasRails::Application::Queue = TapasRails::Resque::Queue.new('tapas_rails')
