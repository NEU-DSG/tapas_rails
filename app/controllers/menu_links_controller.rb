class MenuLinksController < ApplicationController
  extend ActiveSupport::Concern
  before_filter :verify_admin, :except => :show

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render_404(exception)
  end

  included do
    rescue_from ActiveRecord::RecordInvalid do |exception|
      flash[:error] = exception.to_s
      redirect_to '/admin'
    end
  end

  def show
    @menu_link = MenuLink.find(params[:id])
  end

  def edit
    @menu_link = MenuLink.find(params[:id])
    @menus = []
    @menus << ["Main Menu", "main_menu"]
    @menus << ["Documentation Submenu", "documentation_sub"]
    @menus << ["Toolbar - Tools", "toolbar_tools"]
  end

  def update
    @menu_link = MenuLink.find(params[:id])
    @menu_link.update_attributes(menu_link_params)
    if @menu_link.valid?
      @menu_link.save!
      redirect_to(:action => :index)
    else
      flash.now[:error] = @menu_link.errors.full_messages.join(",")
      render(:action => :edit)
    end
  end

  def new
    @menu_link_title = "New Menu Link"
    @menu_link = MenuLink.new
    @menus = []
    @menus << ["Main Menu", "main_menu"]
    @menus << ["Documentation Submenu", "documentation_sub"]
    @menus << ["Toolbar - Tools", "toolbar_tools"]
  end

  def create
    @menu_link = MenuLink.new(menu_link_params)
    if @menu_link.valid?
      @menu_link.save!
      redirect_to(:action => :index)
    else
      flash.now[:error] = @menu_link.errors.full_messages.join(",")
      render(:action => :new)
    end
  end

  def index
    @menu_link_title = "Menu Links"
    @main_menu_links = MenuLink.all.where(:menu_name=>"main_menu").order(:link_order)
    @documentation_sub_links = MenuLink.all.where(:menu_name=>"documentation_sub").order(:link_order)
    @toolbar_tools_links = MenuLink.all.where(:menu_name=>"toolbar_tools").order(:link_order)
  end

  def update_menu_order
    logger.info params
    logger.info "in update_menu_order"
    params[:menu_order].each do |i, l|
      link = MenuLink.find(l["id"])
      link.link_order = i
      link.save!
      if l["children"]
        l["children"].each do |x, l_c|
          link_c = MenuLink.find(l_c["id"])
          link_c.link_order = x
          link_c.parent_link_id = l["id"]
          link_c.save!
        end
      end
    end
    respond_to do |format|
      format.json { render :json=>{:status=>"Success", :links=>MenuLink.all.where(:menu_name=>params[:menu_name]).to_json}, status: 200}
    end
  end

  private

    def verify_admin
      redirect_to root_path unless current_user.admin?
    end

    def menu_link_params
      params.require(:menu_link).permit(:link_text, :link_href, :link_order, :classes, :parent_link_id, :menu_name)
    end
end
