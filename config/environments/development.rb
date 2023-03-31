# pre-upgrade - 03272023 by CCH

TapasRails::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  Rails.application.routes.default_url_options[:host] = 'localhost:3000'
  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false
  config.reload_classes_only_on_change = false

  # Do not eager load code on boot.
  config.eager_load = false

  config.log_level = :debug

  # config.fedora_home = "#{Rails.root.to_s}/jetty/fedora/default/data/datastreamStore/"

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { host: "localhost:3000" }
  config.action_mailer.delivery_method = :smtp

  # Use mailcatcher (https://mailcatcher.me/) to test emails locally
  # NOTE: Please do not put mailcatcher in the Gemfile, as it will cause conflicts
  config.action_mailer.smtp_settings = { address: "localhost", port: 1025 }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # config.active_storage.service = :amazon

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  # config.assets.debug = true
  config.assets.compress = false

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

  config.file_watcher = ActiveSupport::FileUpdateChecker

  config.reload_classes_only_on_change = false
  config.log_level = :info
end

# Rails.application.configure do
#   # Settings specified here will take precedence over those in config/application.rb.
#
#   # In the development environment your application's code is reloaded on
#   # every request. This slows down response time but is perfect for development
#   # since you don't have to restart the web server when you make code changes.
#   config.cache_classes = false
#
#   # Do not eager load code on boot.
#   config.eager_load = false
#
#   # Show full error reports.
#   config.consider_all_requests_local = true
#
#   # Enable/disable caching. By default caching is disabled.
#   # Run rails dev:cache to toggle caching.
#   if Rails.root.join('tmp', 'caching-dev.txt').exist?
#     config.action_controller.perform_caching = true
#
#     config.cache_store = :memory_store
#     config.public_file_server.headers = {
#       'Cache-Control' => "public, max-age=#{2.days.to_i}"
#     }
#   else
#     config.action_controller.perform_caching = false
#
#     config.cache_store = :null_store
#   end
#
#   # Store uploaded files on the local file system (see config/storage.yml for options)
#   config.active_storage.service = :local
#
#   # Don't care if the mailer can't send.
#   config.action_mailer.raise_delivery_errors = false
#
#   config.action_mailer.perform_caching = false
#
#   # Print deprecation notices to the Rails logger.
#   config.active_support.deprecation = :log
#
#   # Raise an error on page load if there are pending migrations.
#   config.active_record.migration_error = :page_load
#
#   # Highlight code that triggered database queries in logs.
#   config.active_record.verbose_query_logs = true
#
#   # Debug mode disables concatenation and preprocessing of assets.
#   # This option may cause significant delays in view rendering with a large
#   # number of complex assets.
#   config.assets.debug = true
#
#   # Suppress logger output for asset requests.
#   config.assets.quiet = true
#
#   # Raises error for missing translations
#   # config.action_view.raise_on_missing_translations = true
#
#   # Use an evented file watcher to asynchronously detect changes in source code,
#   # routes, locales, etc. This feature depends on the listen gem.
#   config.file_watcher = ActiveSupport::EventedFileUpdateChecker
# end
