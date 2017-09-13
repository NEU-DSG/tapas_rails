source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.8'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'

# Use rubyzip to handle Zipped content files from Drupal
gem 'rubyzip'

# Use passenger as the application server
gem 'passenger', '5.0.15'

# Use mysql2 for the staging environment
gem 'mysql2', '0.3.16'

gem 'minitest', '4.7.5'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.2'
gem 'bootstrap-sass', '3.3.4.1'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# for handling slugs in URLS instead of IDs
gem 'friendly_id', '~> 5.0.0' # Note: You MUST use 5.0.0 or greater for Rails 4.0+
# hand to downgrade from 5.1.0 to 5.0.0 for forem to work

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

# Use Figaro to manage sensitive application configuration
gem 'figaro'

# Use CerberusCore as the basis for this project
gem 'cerberus_core', git: "https://github.com/NEU-Libraries/cerberus_core.git", :branch => "master"

# Use Resque to handle background tasks
gem 'resque', :require => 'resque/server'

# Use Nest because some inherited config uses Nest
gem 'nest'

# Use thor for command line tasks
gem 'thor'

# Install thor-rails to write thor tasks that are rails env aware
gem 'thor-rails'

# Use Namae to try to parse arbitrary names
gem 'namae'

# Bootstrap WYSIWYG Editor
gem 'bootsy'

# Forem gem for Forums
gem 'forem', git: "https://github.com/radar/forem.git", :branch => "rails4"

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
  gem "rspec-rails", "~>2.15"
  gem "rspec-its"
  gem "jettywrapper"
  gem "factory_girl_rails"
end

gem "devise"
gem "devise-guests", "~> 0.3"

gem "rsolr", "~> 1.0.6"
gem 'therubyracer',  platforms: :ruby


gem 'simplecov', :require => false, :group => :test
gem 'simplecov-json', :require => false, :group => :test
gem 'simplecov-rcov', :require => false, :group => :test
gem "git", :git => 'https://github.com/schacon/ruby-git.git'
