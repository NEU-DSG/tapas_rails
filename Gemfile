source 'https://rubygems.org'

gem 'rails', '5.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use Capistrano for deployment
gem 'capistrano', '~> 3.1', group: :development
gem 'capistrano-rails', '~> 1.1'
gem 'capistrano-rvm'
gem 'capistrano-resque', '~> 0.2.2', :require => false
gem 'capistrano-passenger'
gem 'capistrano-git-submodule-strategy', '~> 0.1', :git => 'https://github.com/ekho/capistrano-git-submodule-strategy.git'

group :development, :test do
  gem 'factory_bot_rails'
  gem 'jettywrapper'
  gem 'pry'
  gem 'rspec-its'
  gem 'rspec-rails', '~> 3'
end

gem 'aws-sdk-s3', require: false
gem 'blacklight-gallery'
gem 'blacklight'
gem 'cancancan'
gem 'carrierwave', '~> 1.3.1'
gem 'coffee-rails', '~> 5.0.0'
gem 'devise_invitable', '~> 2.0.0'
gem 'devise-guests', '~> 0.3'
gem 'devise'
gem 'discard', '~> 1.2'
gem 'exception_notification'
gem 'figaro'
gem 'forty_facets'
gem 'friendly_id', '~> 5.2.4' # Note: You MUST use 5.0.0 or greater for Rails 4.0+
gem 'git'
gem 'haml-rails', '~> 2.0'
gem 'hydra-derivatives'
gem 'hydra-head', '~> 10.0'
gem 'jbuilder', '2.10'
gem 'jquery-rails'
gem 'json', '~> 2.3'
gem 'mods_display', '~> 0.3'
gem 'mysql2', '0.5.3'
gem 'namae'
# Use Nest because some inherited config uses Nest
gem 'nest'
gem 'nokogiri'
gem 'openseadragon'
gem 'parseconfig'
gem 'passenger', '6.0.4'
gem 'rails_config'
gem 'resque', :require => 'resque/server'
gem 'rest-client'
gem 'rubyzip'
gem 'sass-rails'
gem 'simple_form'
gem 'simplecov-json', :require => false, :group => :test
gem 'simplecov-rcov', :require => false, :group => :test
gem 'simplecov', :require => false, :group => :test
gem 'sprockets', '~> 3.7.2'
gem 'therubyracer', platforms: :ruby
gem 'turbolinks'
gem 'uglifier', '>= 1.3.0'
