class CollectionsController < CatalogController
  include ApiAccessible

  before_action :authorize_edit!, only: %i[destroy edit update]
  before_action :authorize_read!, only: :show

  def index
    @page_title = 'All Collections'
    @results = Collection.order(updated_at: :desc)

    respond_to do |format|
      format.html { render template: 'shared/index' }
      format.js { render template: 'shared/index', layout: false }
    end
  end

  def show
    @collection = Collection.find(params[:id])
    @page_title = @collection.title
  end

  def new
    @collection = Collection.new

    authorize!(:new, @collection)

    @page_title = 'Create New Collection'
    @communities = Community.joins(:community_members)
                            .where(community_members: { user_id: current_user.id, member_type: %w[editor admin] })
  end

  def create
    @collection = Collection.new(collection_params)

    authorize!(:create, @collection)

    @collection.depositor = current_user
    @collection.save!

    redirect_to @collection
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

    redirect_to @collection
  end

  protected

  def authorize_edit!
    collection = Collection.find(params[:id])
    authorize! :manage, collection
  end

  def authorize_read!
    collection = Collection.find(params[:id])
    authorize! :read, collection
  end

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
