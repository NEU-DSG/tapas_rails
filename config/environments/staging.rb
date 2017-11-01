TapasRails::Application.configure do

  config.cache_classes = true
  config.fedora_home = "/opt/fedora/data/datastreamStore/"

  config.eager_load = true

  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.action_mailer.default_url_options = { :host => "tapasdev.neu.edu"}

  config.assets.js_compressor = :uglifier

  config.assets.compile = true

  config.assets.digest = true

  config.assets.version = "1.0"

  config.log_level = :debug

  config.i18n.fallbacks = true

  config.active_support.deprecation = :notify

  config.log_formatter = ::Logger::Formatter.new

  config.middleware.use ExceptionNotification::Rack,
    :email => {
      :email_prefix => "[Tapas Rails Notifier DEV]",
      :sender_address => %{"notifier" <notifier@tapasrails.neu.edu>},
      :exception_recipients => "e.zoller@northeastern.edu"
    }

end
