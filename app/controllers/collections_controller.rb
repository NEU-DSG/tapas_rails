class CollectionsController < CatalogController
  include ApiAccessible
  include ControllerHelper

  self.copy_blacklight_config_from(CatalogController)

  before_action :can_edit?, only: [:edit, :update, :destroy]
  before_action :can_read?, :only => :show
  # before_action :enforce_show_permissions, :only=>:show

  def upsert
    if params[:thumbnail]
      params[:thumbnail] = create_temp_file(params[:thumbnail])
    end

    TapasRails::Application::Queue.push TapasObjectUpsertJob.new params
    @response[:message] = "Collection upsert accepted"
    pretty_json(202) and return
  end

  def index
    @page_title = "All Collections"
    # self.search_params_logic += [:collections_filter]
    # self.search_params_logic += [:add_access_controls_to_solr_params]
    (@response, @document_list) = search_results(params) #, search_params_logic)
    respond_to do |format|
      format.html { render :template => 'shared/index' }
      format.js { render :template => 'shared/index', :layout => false }
    end
  end

  def show
    @collection = Collection.find(params[:id])
    @page_title = @collection.title
  end

  def new
    @page_title = "Create New Collection"
    @communities = Community.joins(:community_members).where(community_members: { user_id: current_user.id, member_type: ["editor", "admin"] })
    @collection = Collection.new(community: @community)
  end

  def create
    @collection = Collection.new(collection_params)
    @collection.depositor = current_user
    @collection.save!

    # if (params[:thumbnail])
    #   params[:thumbnail] = create_temp_file(params[:thumbnail])
    #   @collection.add_thumbnail(:filepath => params[:thumbnail])
    #   @collection.save!
    # end
    # can this be used instead of individually spelling out the methods?
    # TapasRails::Application::Queue.push TapasObjectUpsertJob.new params

    redirect_to @collection and return
  end

  def edit
    model_type = RSolr.solr_escape "info:fedora/afmodel:Community"
    count = ActiveFedora::SolrService.count("has_model_ssim:\"#{model_type}\"")
    results = ActiveFedora::SolrService.query("has_model_ssim:\"#{model_type}\"", fl: 'id, title_info_title_ssi', rows: count)
    @communities =[]
    results.each do |res|
      if !res['title_info_title_ssi'].blank? && !res['id'].blank?
        @communities << [res['title_info_title_ssi'],res['id']]
      end
    end
    @collection = Collection.find(params[:id])
    @page_title = "Edit #{@collection.title}"
  end

  def update
    community = Community.find(params[:community]) if params[:community]
    params[:collection].delete("community")
    @collection = Collection.find(params[:id])
    # @core_files = CoreFile.find_by_did(params[:id])
    if params[:collection][:remove_thumbnail] == "1"
      params[:collection].delete :thumbnail
      @collection.thumbnails = []
      @collection.save!
    end
    params[:collection].delete :remove_thumbnail
    @collection.update_attributes(params[:collection])
    @collection.mass_permissions = params[:mass_permissions]
    @collection.save!
    @collection.community = community if community
    @collection.save!

    if (params[:thumbnail])
      params[:thumbnail] = create_temp_file(params[:thumbnail])
      @collection.add_thumbnail(:filepath => params[:thumbnail])
      @collection.save!
    end
    # can this be used instead of individually spelling out the methods?
    # TapasRails::Application::Queue.push TapasObjectUpsertJob.new params

    redirect_to @collection and return
  end

  protected

  def can_read?
    collection = Collection.find(params[:id])
    can? :read, collection
  end

  private

  def collection_params
    params
      .require(:collection)
      .permit(
        :community_id,
        :description,
        :is_public,
        :title
      )
  end
end
