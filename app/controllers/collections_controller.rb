class CollectionsController < CatalogController
  include ApiAccessible

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

    redirect_to @collection and return
  end

  def destroy
    collection = Collection.find(params[:id])
    community = collection.community

    collection.discard!

    redirect_to community
  end

  def edit
    @collection = Collection.find(params[:id])
    @communities = Community.accessible_by(current_ability)
    @page_title = "Edit #{@collection.title}"
  end

  def update
    @collection = Collection.find(params[:id])
    @collection.update(collection_params)

    redirect_to @collection and return
  end

  protected

  def can_edit?
    collection = Collection.find(params[:id])
    can? :manage, collection
  end

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
        :title,
        thumbnails: []
      )
  end
end
