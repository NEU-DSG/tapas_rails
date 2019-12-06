class ViewPackage < ActiveRecord::Base
  include TapasRails::ViewPackages
  attr_accessible :human_name, :machine_name, :description, :file_type, :css_files, :js_files, :parameters, :run_process, :dir_name, :git_timestamp, :git_branch if Rails::VERSION::MAJOR < 4

  serialize :file_type, Array
  serialize :css_files, Array
  serialize :js_files, Array
  serialize :parameters, Hash
  serialize :run_process, Hash

  after_destroy :clear_cache
  after_save :clear_cache

  def clear_cache
    arr_before = available_view_packages_machine
    Rails.cache.delete("view_packages_machine")
    Rails.cache.delete("view_packages_dir")
    arr_after = available_view_packages_machine
    arr_before.reject!{|x| arr_after.include? x}
    CoreFile.remove_view_package_methods(arr_before)
  end
end
