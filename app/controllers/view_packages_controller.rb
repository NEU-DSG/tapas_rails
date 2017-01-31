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
      dir_name = view.machine_name.sub("_","-")
      if view.js_dir
        js_dir = Rails.root.join("public/view_packages/#{dir_name}/#{view.js_dir}")
        logger.info js_dir
        logger.info Dir[js_dir+"*"]
        view.js_dir = Dir[js_dir+"*"]
      end
      if view.css_dir
        css_dir =  Rails.root.join("public/view_packages/#{dir_name}/#{view.css_dir}")
        logger.info css_dir
        logger.info Dir[css_dir+"*.css"]
        view.css_dir = Dir[css_dir+"*.css"]
      end
    end
    render json: @view_packages
  end
end
