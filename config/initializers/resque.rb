require 'resque'

rails_root = Rails.root
rails_env = Rails.env

Resque.redis = $redis if defined?($redis)
Resque.logger = Logger.new(rails_root.join('log', "#{rails_env}_resque.log"))
