class ProjectsController < ApplicationController
  include ApiAccessible

  # figure out why this controller doesn't inherit from CatalogController the way CoreFilesController does

  before_action :can_edit?, only: [:edit, :update, :destroy]
  before_action :can_read?, :only => :show
  # before_action :enforce_show_permissions, :only=>:index

  # self.search_params_logic += [:add_access_controls_to_solr_params]

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
      # @institutions = Institution.pluck(:name, :id)
      @users = format_users_for_form
    end
  end

  # Projects have many collections; each collection belongs to one project; CoreFiles can belong to many
  # collections (many-to-many), but will always point back to one project

  def create
    @project = Project.create!(project_params.merge({ depositor_id: current_user.id }))

    # add_institutions
    add_members

    redirect_to @project
  end

  #This method is used to edit a particular project
  def edit
    @project = Project.find(params[:id])
    @page_title = "Edit #{@project.title || ''}"
    # @institutions
    @users = format_users_for_form
  end

  def update
    @project = Project.find(params[:id])
    # @project.project_members.destroy_all
    # @project.institutions.destroy_all
    @project.update(project_params)

    # add_institutions
    # add_members

    if params[:project][:remove_image_file].present?
      @project.image_file.purge_later
    end

    redirect_to @project
  end

  # def add_institutions
  #   child_params[:institutions].reject(&:empty?).map { |iid| ProjectInstitution.create!(project_id: @project.id, institution_id: iid) }
  # end

  def add_members
    child_params[:project_members].reject(&:empty?).map { |uid| ProjectMember.create(project_id: @project.id, user_id: uid, role: 'member') }
    child_params[:project_editors].reject(&:empty?).map { |uid| ProjectMember.create!(project_id: @project.id, user_id: uid, role: 'editor') }
    child_params[:project_admins].reject(&:empty?).map { |uid| ProjectMember.create!(project_id: @project.id, user_id: uid, role: 'admin') }

    unless child_params[:project_admins].include?(current_user.id.to_s)
      ProjectMember.create!(project_id: @project.id, user_id: current_user.id, role: 'admin')
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
        :title
      )
  end

  def child_params
    params.require(:project).permit(
      # :institutions => [],
      :project_admins => [],
      :project_editors => [],
      :project_members => []
    )
  end
end
