class CatalogController < ApplicationController

  def search_action_url
    catalog_index_path(options.except(:controller, :action))
  end

  def index
    @page_title = "Catalog"
    @model = catalog_params[:model] || "core_file"
    @search = case @model.downcase
    when "core_file"
      CoreFileSearch.new(params)
    when "community"
      CommunitySearch.new(params)
    when "collection"
      CollectionSearch.new(params)
    else
      CoreFileSearch.new(params)
    end

    @results = @search.result

    respond_to do |format|
      format.html { render :template => 'shared/index' }
      format.js { render :template => 'shared/index', :layout => false }
    end
  end

  protected

  def catalog_params
    params.permit(:model)
  end
end
