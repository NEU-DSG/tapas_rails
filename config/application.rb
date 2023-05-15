require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TapasRails
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    config.generators do |g|
      g.test_framework :rspec, :spec => true
    end

    config.autoload_paths += Dir[Rails.root.join('app', 'models', '**/')]
    config.autoload_paths += Dir[Rails.root.join('app', 'validators', '**/')]
    config.autoload_paths += Dir[Rails.root.join('app', 'actions', '**/')]
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    # Dir.glob("#{config.root}/lib/**/[^spec]**/").each do |dir|
    #   puts dir
    #   config.autoload_paths << dir
    # end


    config.secret_key_base = ENV["SECRET_KEY_BASE"]

    # Pid to use for the Collection that stores TEI files
    # that reference non-existant collections.
    config.phantom_collection_pid = "tap:phantom"

    # Pid to use for the Project that is the graph root for
    # the tapas repository.  Note that this doesn't map to any
    # project object that exists in the drupal head.
    config.tap_root = "tap:1"
    config.encoding = "utf-8"

    # Enable pid generation on object instantiation
    # config.cerberus_core.auto_generate_pid = true

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.filter_parameters << :token
  end
end
