source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.2.6'

# Use rubyzip to handle Zipped content files from Drupal
gem 'rubyzip'

gem 'sprockets-rails', :require => 'sprockets/railtie'

# Use passenger as the application server
gem 'passenger', '6.0.4'

# Use mysql2 for the staging environment
gem 'mysql2', '0.5.3'

# gem 'sass-rails', '~> 4.0.2'
gem 'bootstrap-sass', '3.3.4.1'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'dotenv-rails', groups: [:development, :test]
# loads environment variables from .env into ENV in development
# https://github.com/bkeepers/dotenv/

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# for handling slugs in URLS instead of IDs
gem 'friendly_id', '~> 5.2.4' # Note: You MUST use 5.0.0 or greater for Rails 4.0+

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '2.10'

# Use Figaro to manage sensitive application configuration
gem 'figaro'

# Use Resque to handle background tasks
gem 'resque', :require => 'resque/server'

# Use Nest because some inherited config uses Nest
gem 'nest'

gem 'discard', '~> 1.2'

# Use Namae to try to parse arbitrary names
gem 'namae'

# Configure email alerts on exception
gem 'exception_notification'

# Use ParseConfig to do some exception mailer related conf
gem 'parseconfig'

# Use rest-client to handle building calls to eXist
gem 'rest-client'

# Use rails_config gem for less crappy custom config
gem 'rails_config'

# Use mods_display to generate html from mods
gem 'mods_display', '~> 0.3'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

gem "blacklight"
gem 'blacklight-gallery'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
gem 'capistrano', '~> 3.1', group: :development
gem 'capistrano-rails', '~> 1.1'
gem 'capistrano-rvm'
gem 'capistrano-resque', '~> 0.2.2', :require => false
gem 'capistrano-passenger'
gem 'capistrano-git-submodule-strategy', '~> 0.1', :git => 'https://github.com/ekho/capistrano-git-submodule-strategy.git'

# Use debugger
# gem 'debugger', group: [:development, :test]

group :development, :test do
  gem "pry"
  gem "rspec-rails", "~> 3"
  gem "rspec-its"
  gem "factory_bot_rails"
end

gem "devise"
gem "devise-guests", "~> 0.3"
gem 'devise_invitable', '~> 2.0.0'
gem "cancancan"

gem "rsolr"

gem 'simplecov', :require => false, :group => :test
gem 'simplecov-json', :require => false, :group => :test
gem 'simplecov-rcov', :require => false, :group => :test
gem "git"

gem "json", "~> 2.3"
gem 'simple_form'
gem 'openseadragon'

gem "haml-rails", "~> 2.0"
gem 'carrierwave', '~> 1.3.1'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 5.0.0'
