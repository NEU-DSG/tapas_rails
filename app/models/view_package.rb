class ViewPackage < ActiveRecord::Base
  attr_accessible :human_name, :machine_name, :description, :file_type, :css_dir, :js_dir, :parameters, :run_process if Rails::VERSION::MAJOR < 4

  serialize :file_type, Array
  serialize :parameters, Hash
  serialize :run_process, Hash


  # TODO make a job which communicates with github to dynamically add these
  # TODO need to figure out where the assets will be stored for each of these and how to retrieve them in the interface when necessary

  after_destroy :clear_cache
  after_save :clear_cache

  def clear_cache
    Rails.cache.delete("view_packages")
  end
end
