source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.8'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'

# Use rubyzip to handle Zipped content files from Drupal
gem 'rubyzip'

# Use mysql2 for the staging environment 
gem 'mysql2'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.2'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

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

# Configure email alerts on exception
gem 'exception_notification'

# Use ParseConfig to do some exception mailer related conf
gem 'parseconfig'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
gem 'capistrano', '~> 3.1', group: :development
gem 'capistrano-rails', '~> 1.1'
gem 'capistrano-rvm'

# Use debugger
# gem 'debugger', group: [:development, :test]

group :development, :test do
  gem "rspec-rails"
  gem "jettywrapper"
  gem "factory_girl_rails"
end

gem "devise"
gem "devise-guests", "~> 0.3"
