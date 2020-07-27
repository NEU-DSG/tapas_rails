class UsersController < CatalogController

  self.copy_blacklight_config_from(CatalogController)
  before_action :check_for_logged_in_user, :only => [:my_tapas, :my_projects]
  before_action :verify_admin, :only => [:index, :show, :create, :delete, :admin_show]

  def my_tapas
    @page_title = "My TAPAS"
    @user = current_user
    @projects = five_communities
    @collections = five_collections
    @records = five_records
    render 'my_tapas'
  end

  def my_projects
    @page_title = "My Projects"
    @user = current_user
    @projects = @user.communities

    render 'my_projects'
  end

  def my_collections
    @page_title = "My Collections"
    @user = current_user
    # self.search_params_logic += [:my_collections_filter]
    (@collections, @document_list) = search_results(params) #, search_params_logic)
    render 'my_collections'
  end

  def my_records
    @page_title = "My Records"
    @user = current_user
    # self.search_params_logic += [:my_records_filter]
    (@records, @document_list) = search_results(params) #, search_params_logic)
    render 'my_records'
  end

  def index
    @page_title = "Users"
    @users = User.order(:name, :email)
    @users = @users.where("name like ? or email like ?", "%#{params[:term]}%", "%#{params[:term]}%") if params[:term]

    respond_to do |format|
      format.html  # index.html.erb
      format.json  { render json: @users.map(&:email) }
    end
  end

  def admin_show
    @user = User.find(params[:id])
    render 'show'
  end

  def profile
    @user = User.find(params[:id])
    render 'profile'
  end

  def edit
    @user = User.find(params[:id])
    i_s = Institution.all()
    @institutions = []
    i_s.each do |i|
      @institutions << [i.name, i.id]
    end
  end

  def update
    @user = User.find(params[:id])
    @user.name = params[:user][:name]
    @user.email = params[:user][:email]
    @user.role = params[:user][:role]
    @user.account_type = params[:user][:account_type]
    @user.institution = Institution.find(params[:user][:institution_id])
    @user.save!
    redirect_to @user
  end

  def destroy
    user = User.find(params[:id])

    if user.discarded?
      user.delete
    else
      user.discard
    end

    redirect_to users_path
  end

  def search_action_url(options = {})
    # Rails 4.2 deprecated url helpers accepting string keys for 'controller' or 'action'
    # catalog_index_path(options.except(:controller, :action))
    "/"
  end

  def mail_all_users
    if params[:subject] && params[:content]
      subj = params[:subject]
      content = params[:content]
      User.all.each do |u|
        if u.email != "tapas@neu.edu"
          Resque.enqueue(SendMailJob, u, subj, content)
        end
      end
      flash[:notice] = "Mail was sent to all users"
      redirect_to "/admin"
    else
      render "mail_all_users"
    end
  end

  private

  def five_communities
    @user.communities.kept.limit(5).order("RAND()")
  end

  def five_collections
    Collection
      .kept
      .accessible_by(current_ability)
      .limit(5)
      .order("RAND()")
  end

  def five_records
    CoreFile
      .kept
      .accessible_by(current_ability)
      .limit(5)
      .order("RAND()")
  end

  def my_communities_filter(solr_parameters, user_parameters)
    model_type = RSolr.solr_escape "info:fedora/afmodel:Community"
    query = "has_model_ssim:\"#{model_type}\" && (project_members_ssim:\"#{@user.id.to_s}\" OR depositor_tesim:\"#{@user.id.to_s}\" OR project_admins_ssim:\"#{@user.id.to_s}\" OR project_editors_ssim:\"#{@user.id.to_s}\")"
    logger.error query
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << query
    end

  def my_collections_filter(solr_parameters, user_parameters)
    model_type = RSolr.solr_escape "info:fedora/afmodel:Collection"
    projects = ActiveFedora::SolrService.query("has_model_ssim:\"#{RSolr.solr_escape "info:fedora/afmodel:Community"}\" && (project_members_ssim:\"#{@user.id.to_s}\" OR depositor_tesim:\"#{@user.id.to_s}\" OR project_admins_ssim:\"#{@user.id.to_s}\" OR project_editors_ssim:\"#{@user.id.to_s}\")")
    col_query = projects.map do |p|
        "project_pid_ssi: #{RSolr.solr_escape(p['id'])}"
    end
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << col_query.join(" OR ")
    solr_parameters[:fq] << "has_model_ssim: \"#{model_type}\""
  end

  def my_records_filter(solr_parameters, user_parameters)
    model_type = RSolr.solr_escape "info:fedora/afmodel:CoreFile"
    projects = ActiveFedora::SolrService.query("has_model_ssim:\"#{RSolr.solr_escape "info:fedora/afmodel:Community"}\" && (project_members_ssim:\"#{@user.id.to_s}\" OR depositor_tesim:\"#{@user.id.to_s}\" OR project_admins_ssim:\"#{@user.id.to_s}\" OR project_editors_ssim:\"#{@user.id.to_s}\")")
    col_query = projects.map do |p|
      "project_pid_ssi: #{RSolr.solr_escape(p['id'])}"
    end
    collections = ActiveFedora::SolrService.query("has_model_ssim:\"#{RSolr.solr_escape "info:fedora/afmodel:Collection"}\" && (#{col_query.join(" OR ")})")
    rec_query = collections.map do |y|
      "collections_pids_ssim: \"#{RSolr.solr_escape(y['id'])}\""
    end
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << rec_query.join(" OR ")
    solr_parameters[:fq] << "has_model_ssim: \"#{model_type}\""
  end

  def check_for_logged_in_user
    redirect_to new_user_session_path if current_user.nil?
  end

  def verify_admin
    redirect_to root_path unless current_user && current_user.admin?
  end

end
