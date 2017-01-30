TapasRails::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false
  config.reload_classes_only_on_change = false

  # Do not eager load code on boot.
  config.eager_load = false

  config.log_level = :debug

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Parse ~/.gitconfig in an attempt to load the email address of the currently
  # developing developer.  Return a nonsense default otherwise
  conf_path = "#{Dir.home}/.gitconfig"
  if File.exists?(conf_path)
    gitconfig = ParseConfig.new(conf_path)

    if gitconfig['user']
      email = gitconfig['user']['email'] || "changeme@example.com"
    else
      email = "changeme@example.com"
    end
  end

  config.middleware.use ExceptionNotification::Rack,
    :email => {
      :email_prefix => "[Tapas Rails Notifier DEV]",
      :sender_address => %{"notifier" <notifier@tapasrails.neu.edu>},
      :exception_recipients => email
    }
end
