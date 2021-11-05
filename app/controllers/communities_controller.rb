class CommunitiesController < CatalogController
  include ApiAccessible

  self.copy_blacklight_config_from(CatalogController)

  before_action :can_edit?, only: [:edit, :update, :destroy]
  before_action :can_read?, :only => :show
  # before_action :enforce_show_permissions, :only=>:index

  # self.search_params_logic += [:add_access_controls_to_solr_params]

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

    logger.debug repository.inspect
    logger.debug repository.connection

    (@response, @document_list) = search_results(params) #, search_params_logic)
    respond_to do |format|
      format.html { render :template => 'shared/index' }
      format.js { render :template => 'shared/index', :layout => false }
    end
  end

  def show
    @community = Community.find(params[:id])
    @page_title = @community.title || ""
    @collections = @community.collections
  end

  def format_users_for_form
    User.pluck(:name, :email, :id).map { |u| ["#{u[0]} (#{u[1]})", u[2]] }
  end

  def new
    if current_user && (current_user.paid_user? || current_user.admin?)
      @page_title = "Create New Community"
      @community = Community.new
      @institutions = Institution.pluck(:name, :id)
      @users = format_users_for_form
    else
      flash[:notice] = "In order to create a project, you must be a member of the TEI. <a href="">Join now!</a>"
      redirect_to root_path
    end
  end

  # TODO: Projects have many collections; each collection belongs to one project
  # TODO: CoreFiles can belong to many collections (many-to-many), but will always point back to one project

  def create
    @community = Community.new(community_params)
    @community.depositor = current_user
    @community.save!

    if (thumbnail_params[:thumbnail])
      # TODO: (pletcher) Create Thumbnail by uploading (to S3?) and saving URL
      # Thumbnail.create!(url: url, owner: @community)
    end

    redirect_to @community
  end

  #This method is used to edit a particular community
  def edit
    @community = Community.find(params[:id])
    @page_title = "Edit #{@community.title || ''}"
    @institutions = Institution.pluck(:name, :id)
    @users = format_users_for_form
  end

  def update
    @community = Community.find(params[:id])
    @community.community_members.destroy_all
    @community.communities_institutions.destroy_all
    @community.update(community_params)

    redirect_to @community
  end

  def destroy
    community = Community.find(params[:id])
    community.destroy

    redirect_to my_tapas_path
  end

  protected

  def can_edit?
    community = Community.find(params[:id])
    can? :manage, community
  end

  def can_read?
    community = Community.find(params[:id])
    can? :read, community
  end

  private

  def community_params
    params
      .require(:community)
      .permit(
        :description,
        :thumbnail,
        :title,
        :institutions => [],
        :project_admins => [],
        :project_editors => [],
        :project_members => []
      )
  end

  def thumbnail_params
    params.permit(:thumbnail)
  end
end
