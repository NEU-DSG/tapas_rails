TapasRails::Application.configure do

  config.cache_classes = true
  config.fedora_home = "/opt/fedora/data/datastreamStore/"

  config.eager_load = true

  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  config.assets.js_compressor = :uglifier

  config.assets.compile = true

  config.assets.digest = true

  config.assets.version = "1.0"

  config.log_level = :debug

  config.i18n.fallbacks = true

  config.active_support.deprecation = :notify

  config.log_formatter = ::Logger::Formatter.new
end
