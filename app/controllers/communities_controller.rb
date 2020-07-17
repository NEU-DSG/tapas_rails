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

  def new
    if current_user && (current_user.paid_user? || current_user.admin?)
      @page_title = "Create New Community"
      @community = Community.new
      i_s = Institution.all()
      @institutions = []
      i_s.each do |i|
        @institutions << [i.name, i.id]
      end
      u_s = User.all()
      @users = []
      u_s.each do |u|
        @users << ["#{u.name} (#{u.email})", u.id]
      end
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

    params[:community][:project_admins].each do |a|
      CommunityMember.find_or_create_by(community: @community, user_id: a, member_type: 'admin')
    end

    params[:community][:project_editors].each do |e|
      CommunityMember.create!(community: @community, user_id: e, member_type: 'editor')
    end

    params[:community][:project_members].each do |m|
      CommunityMember.create!(community: @community, user_id: m, member_type: 'member')
    end

    if (thumbnail_params[:thumbnail])
      # TODO: (pletcher) Create Thumbnail by uploading (to S3?) and saving URL
      # Thumbnail.create!(url: url, owner: @community)
    end

    redirect_to @community and return
  end

  #This method is used to edit a particular community
  def edit
    @community = Community.find(params[:id])
    @page_title = "Edit #{@community.title || ''}"
    i_s = Institution.all()
    @institutions = []
    i_s.each do |i|
      @institutions << [i.name, i.id]
    end
    u_s = User.all()
    @users = []
    u_s.each do |u|
      @users << ["#{u.name} (#{u.email})", u.id]
    end
  end

  #This method contains the actual logic for editing a particular community
  def update
    @community = Community.find(params[:id])
    puts @community
    if params[:community][:remove_thumbnail] == "1"
      params[:community].delete :thumbnail
      @community.thumbnails = []
      @community.save!
    end
    params[:community].delete :remove_thumbnail
    @community.update_attributes(params[:community])
    if params[:mass_permissions]
      @community.mass_permissions = params[:mass_permissions]
    end
    if params[:thumbnail]
      params[:thumbnail] = create_temp_file(params[:thumbnail])
      @community.add_thumbnail(:filepath => params[:thumbnail])
    end

    @community.save!
    redirect_to @community and return
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
        :institutions,
        :project_admins,
        :project_editors,
        :project_members,
        :thumbnail,
        :title
      )
  end

  def thumbnail_params
    params.permit(:thumbnail)
  end
end
