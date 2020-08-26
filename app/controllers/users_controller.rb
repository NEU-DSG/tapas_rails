class UsersController < CatalogController

  self.copy_blacklight_config_from(CatalogController)
  before_action :check_for_logged_in_user, :only => [:my_tapas, :my_projects]
  before_action :verify_admin, :only => [:index, :show, :create, :delete, :admin_bulk_destroy, :admin_index, :admin_show]

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
    @results = @user.communities

    render 'my_projects'
  end

  def my_collections
    @page_title = "My Collections"
    @user = current_user
    @results = Collection.kept.accessible_by(current_ability)
    render 'my_collections'
  end

  def my_records
    @page_title = "My Records"
    @user = current_user
    @results = CoreFile.kept.accessible_by(current_ability)
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

  def admin_bulk_actions
    # NOTE: (charles) We have disabled checking both boxes in JavaScript,
    # but the admin might have worked around that. To be safe, we're going
    # to assume that if the admin has checked a user's restore check box,
    # then we should restore it --- thus we take the difference
    # `params[:destroy_user_ids] - params[:restore_user_ids]` when determining
    # which users to destroy
    restore_users = User.where(id: params[:restore_user_ids])
    destroy_users = User.where(id: params[:destroy_user_ids] - params[:restore_user_ids])

    restore_users.each do |user|
      user.undiscard
    end

    destroy_users.each do |user|
      user.discarded? ? user.delete : user.discard
    end

    redirect_to admin_users_path
  end

  def admin_index
    @users = User.order(:name, :email)
    @users = @users.where("name like ? or email like ?", "%#{params[:term]}%", "%#{params[:term]}%") if params[:term]
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
    @institutions = Institution.select(:name, :id)
  end

  def update
    @user = User.find(params[:id])
    @user.update(user_params)
    flash[:notice] = "#{@user.email} was updated"

    redirect_to edit_user_path(@user)
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

  def user_params
    params.require(:user).permit(
      :name,
      :email,
      :institution_id,
      :account_type,
      :admin,
      :paid
    )
  end

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

  def check_for_logged_in_user
    redirect_to new_user_session_path if current_user.nil?
  end

  def verify_admin
    redirect_to root_path unless current_user && current_user.admin?
  end

end
