# Load the Rails application.
require File.expand_path('../application', __FILE__)

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# Initialize the Rails application.
TapasRails::Application.initialize!

# ActionView complains in tests if we don't copy this config over
TapasRails::Application.default_url_options = TapasRails::Application.config.action_mailer.default_url_options
