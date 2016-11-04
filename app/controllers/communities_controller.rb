class CommunitiesController < CatalogController
  include ApiAccessible
  self.copy_blacklight_config_from(CatalogController)

  def upsert
    if params[:thumbnail]
      params[:thumbnail] = create_temp_file(params[:thumbnail])
    end

    TapasRails::Application::Queue.push TapasObjectUpsertJob.new params
    @response[:message] = "Community upsert in progress"
    pretty_json(202) and return
  end

  # def destroy
  #   @community.descendents.each { |descendent| descendent.destroy }
  #   @community.destroy
  #   @response[:message] = "Project successfully destroyed"
  #   pretty_json(200) and return
  # end

  def index
    @page_title = "All Projects"
    self.search_params_logic += [:communities_filter]
    (@response, @document_list) = search_results(params, search_params_logic)
    render 'shared/index'
  end

  # def show #inherited from catalog controller
  # end

  def communities_filter(solr_parameters, user_parameters)
    model_type = ActiveFedora::SolrService.escape_uri_for_query "info:fedora/afmodel:Community"
    query = "has_model_ssim:\"#{model_type}\""
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << query
  end

  def new
    @page_title = "Create New Community"
    @community = Community.new
  end

  def create
    @community = Community.new(params[:community])
    @community.did = @community.pid
    @community.save!
    redirect_to @community and return
  end

  def edit
    @community = Community.find(params[:id])
    @page_title = "Edit #{@community.title}"
  end

  def update
    @community = Community.find(params[:id])
    @community.update_attributes(params[:community])
    @community.save!
    redirect_to @community and return
  end
end
