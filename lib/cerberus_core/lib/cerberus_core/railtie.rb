require 'rails'

module CerberusCore
  class Railtie < Rails::Railtie
    railtie_name :cerberus_core

    # Any configuration loaded in the Railtie that needs access 
    # to the application's root directory should go inside this 
    # block
    initializer "my_engine.load_app_root" do |app|
      CerberusCore.app_root = app.root
    end
    
    rake_tasks do 
      load "#{File.dirname(__FILE__)}/../tasks/cerberus_core_tasks.rake"
    end

    config.cerberus_core = ActiveSupport::OrderedOptions.new
    config.cerberus_core.auto_generate_pid = false
  end
end