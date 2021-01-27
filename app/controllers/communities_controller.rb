class CommunitiesController < ApplicationController
  include ApiAccessible

  before_action :can_edit?, only: [:edit, :update, :destroy]
  before_action :can_read?, only: :show
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

  def index
    @page_title = "All Projects"

    @search = CommunitySearch.new(params)
    @results = @search.result

    respond_to do |format|
      format.html { render template: 'shared/index' }
      format.js { render template: 'shared/index', layout: false }
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
    @community = Community.create!(community_params.merge({ depositor_id: current_user.id }))

    add_institutions
    add_members

    redirect_to @community
  end

  def edit
    @community = Community.find(params[:id])
    @page_title = "Edit #{@community.title || ''}"
    @institutions = Institution.pluck(:name, :id)
    @users = format_users_for_form
  end

  def update
    @community = Community.find(params[:id])
    @community.community_members.destroy_all
    @community.institutions.destroy_all
    @community.update(community_params)

    add_institutions
    add_members

    @community.thumbnail.purge_later if params[:community][:remove_thumbnail].present?

    redirect_to @community
  end

  def add_institutions
    child_params[:institutions].reject(&:empty?).map { |iid| CommunitiesInstitution.create!(community_id: @community.id, institution_id: iid) }
  end

  def add_members
    child_params[:project_members].reject(&:empty?).map { |uid| CommunityMember.create!(community_id: @community.id, user_id: uid, member_type: 'member') }
    child_params[:project_editors].reject(&:empty?).map { |uid| CommunityMember.create!(community_id: @community.id, user_id: uid, member_type: 'editor') }
    child_params[:project_admins].reject(&:empty?).map { |uid| CommunityMember.create!(community_id: @community.id, user_id: uid, member_type: 'admin') }
  end

  def destroy
    community = Community.find(params[:id])
    community.discard

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
        :title
      )
  end

  def child_params
    params.require(:community).permit(
      institutions: [],
      project_admins: [],
      project_editors: [],
      project_members: []
    )
  end
end
