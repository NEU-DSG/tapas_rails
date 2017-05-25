class CommunitiesController < CatalogController
  include ApiAccessible

  self.copy_blacklight_config_from(CatalogController)
  before_filter :can_read?, except: [:index, :show]

  before_filter :enforce_show_permissions, :only=>:show

  self.solr_search_params_logic += [:add_access_controls_to_solr_params]


  def upsert
    if params[:thumbnail]
      params[:thumbnail] = create_temp_file(params[:thumbnail])
    end

    TapasRails::Application::Queue.push TapasObjectUpsertJob.new params
    @response[:message] = "Community upsert in progress"
    pretty_json(202) and return
  end

  #This method displays all the communities/projects created in the database
  def index
    @page_title = "All Projects"
    self.search_params_logic += [:communities_filter]
    (@response, @document_list) = search_results(params, search_params_logic)
    respond_to do |format|
      format.html { render :template => 'shared/index' }
      format.js { render :template => 'shared/index', :layout => false }
    end
  end

  #This method is the helper method for index. It basically gets the communities
  # using solr queries
  def communities_filter(solr_parameters, user_parameters)
    model_type = RSolr.solr_escape "info:fedora/afmodel:Community"
    query = "has_model_ssim:\"#{model_type}\""
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << query
  end

  #This method is used to display various attributes of community
  def show
    authorize! :show, params[:id]
    @community = Community.find(params[:id])
    @page_title = @community.title || ""
  end

  #This method is used to create a new community/project
  def new
    @page_title = "Create New Community"
    @community = Community.new
  end

  #This method contains the actual logic for creating a new community
  def create
    @community = Community.new(params[:community])
    @community.did = @community.pid
    @community.save!
    redirect_to @community and return
  end

  #This method is used to edit a particular community
  def edit
     @community = Community.find(params[:id])
     @page_title = "Edit #{@community.title || ''}"
  end

  #This method contains the actual logic for editing a particular community
  def update
    @community = Community.find(params[:id])
    puts @community
    # @community = Community.find_by_did(params[:id])
    @community.update_attributes(params[:community])
    @community.save!
    if params[:thumbnail]
      params[:thumbnail] = create_temp_file(params[:thumbnail])
      @community.add_thumbnail(:filepath => params[:thumbnail])
    end
    redirect_to @community and return
  end
end
