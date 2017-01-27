class ViewPackagesController < ApplicationController

  def show
    @view = ViewPackage.find(params[:id])
    @page_title = @view.human_name
  end

  def index
    @page_title = "View Packages"
    @view_packages = ViewPackage.all
  end
end
