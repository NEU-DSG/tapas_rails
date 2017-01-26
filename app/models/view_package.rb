class ViewPackage < ActiveRecord::Base
  attr_accessible :human_name, :machine_name, :description, :file_type, :css_dir, :js_dir, :parameters, :run_process if Rails::VERSION::MAJOR < 4

  serialize :file_type, Array
  serialize :parameters, Hash
  serialize :run_process, Hash


  # TODO make a job which communicates with github to dynamically add these
  


end
