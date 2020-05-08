class ViewPackagesController < ApplicationController
  def show
    @view = ViewPackage.find(params[:id])
    @page_title = @view.human_name
  end

  def index
    @page_title = "View Packages"
    @view_packages = ViewPackage.all
  end

  def api_index
    @view_packages = ViewPackage.all(:order => "machine_name")
    @view_packages.each do |view|
      if !view.js_files.blank?
        array = []
        view.js_files.each do |js|
          array << root_url+"view_packages/#{view.dir_name}/#{js}"
        end
        view.js_files = array
      end
      if !view.css_files.blank?
        array = []
        view.css_files.each do |css|
          array << root_url+"view_packages/#{view.dir_name}/#{css}"
        end
        view.css_files = array
      end
    end
    render json: @view_packages
  end

  def run_job
    Resque.enqueue(GetViewPackagesFromGithub)
    flash[:notice] = "The job to update view packages from source has been sent to the queue"
    redirect_to admin_path
  end
end
