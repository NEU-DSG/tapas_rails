class ProjectsController < ApplicationController
  include ApiAccessible
  include Sortable

  # figure out why this controller doesn't inherit from CatalogController the way CoreFilesController does

  before_action :can_edit?, only: [:edit, :update, :destroy]
  before_action :can_read?, :only => :show
  # before_action :enforce_show_permissions, :only=>:index

  # self.search_params_logic += [:add_access_controls_to_solr_params]
  
  def browse
    # The setup method defines @sort_method and @sort_direction for Sortable's sort_string() and the
    # Browse views. The sort method "total_tei" is added to the default sort methods.
    set_sorting([["number of TEI documents", 'total_tei']])
    @projects = Project.publicly_visible.includes(:collections, :core_files, :project_members)
    # TODO: The use of `sort_by` below requires all Projects and Core Files to be loaded into memory —
    #   it won't scale. We need a simple, fast SQL or Solr query, which suggests that it might be useful 
    #   to store the count of CoreFiles associated with Projects (and Collections), and keep it up to
    #   date as CoreFiles are added or removed.
    if @sort_method == 'total_tei'
      @projects = @projects.sort_by { |p| p.core_files.publicly_visible.count }
      if @sort_direction == 'DESC'
        @projects = @projects.reverse
      end
    else
      @projects = @projects.order(sort_string)
    end
    render 'browse'
  end
  
  def upsert
    if params[:image_file]
      params[:image_file] = create_temp_file(params[:image_file])
    end

    TapasRails::Application::Queue.push TapasObjectUpsertJob.new params
    @response[:message] = "Project upsert in progress"
    pretty_json(202) and return
  end

  #This method displays all the projects created in the database
  def index
    @page_title = "All Projects"
    @results = Project.all

    respond_to do |format|
      format.html { render :template => 'shared/index' }
      format.js { render :template => 'shared/index', :layout => false }
    end
  end

  def show
    @project = Project.find(params[:id])
    @page_title = @project.title || ""
    @collections = @project.collections
    @download_path = 'public/assets'

    render 'projects/show' unless @project.nil?
  end

  def format_users_for_form
    User.pluck(:name, :email, :id).map { |u| ["#{u[0]} (#{u[1]})", u[2]] }
  end

  def new
    if current_user
      @page_title = "Create New Project"
      @project = Project.new
      @users = format_users_for_form
    end
  end

  def create
    @project = Project.create!(project_params.merge({ depositor_id: current_user.id }))

    add_members

    redirect_to @project
  end

  def edit
    @project = Project.find(params[:id])
    @page_title = "Edit #{@project.title || ''}"
    @users = format_users_for_form
  end

  def update
    @project = Project.find(params[:id])
    @project.update(project_params)

    if params[:project][:remove_image_file].present?
      @project.image_file.purge_later
    end

    redirect_to @project
  end

  def add_members
    child_params[:contributors].reject(&:empty?).map { |uid| ProjectMember.create(project_id: @project.id, user_id: uid, role: 'contributor') }
    child_params[:collaborators].reject(&:empty?).map { |uid| ProjectMember.create!(project_id: @project.id, user_id: uid, role: 'collaborator') }
    child_params[:owner].reject(&:empty?).map { |uid| ProjectMember.create!(project_id: @project.id, user_id: uid, role: 'owner') }

    unless child_params[:owner].include?(current_user.id.to_s)
      ProjectMember.create!(project_id: @project.id, user_id: current_user.id, role: 'owner')
    end
  end

  def destroy
    project = Project.find(params[:id])
    project.discard

    redirect_to my_tapas_path
  end

  protected

    def can_edit?
      project = Project.find(params[:id])
      can? :manage, project
    end

    def can_read?
      project = Project.find(params[:id])
      can? :read, project
    end

  private

    def project_params
      params
        .require(:project)
        .permit(
          :description,
          :image_file,
          :title,
          :is_public?,
          :institution
        )
    end

    def child_params
      params.require(:project).permit(
        :contributors => [],
        :collaborators => [],
        :owner => []
      )
    end
end
