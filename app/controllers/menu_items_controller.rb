class MenuItemsController < ApplicationController
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
    @menu_item = MenuItem.find(params[:id])
  end

  def edit
    @menu_item = MenuItem.find(params[:id])
  end

  def update
    @menu_item = MenuItem.find(params[:id])
    @menu_item.update_attributes(menu_item_params)
    if @menu_item.valid?
      @menu_item.save!
      redirect_to @menu_item
    else
      flash.now[:error] = @menu_item.errors.full_messages.join(",")
      render(:action => :edit)
    end
  end

  def new
    @menu_item_title = "New Menu Item"
    @menu_item = MenuItem.new
    @users =[]
    User.all.each do |u|
      @users << [u.name, u.id]
    end
  end

  def create
    @menu_item = MenuItem.new(menu_item_params)
    if @menu_item.valid?
      @menu_item.save!
      redirect_to @menu_item
    else
      flash.now[:error] = @menu_item.errors.full_messages.join(",")
      render(:action => :new)
    end
  end

  def index
    @menu_item_title = "Menu Items"
    @menu_items = MenuItem.all
  end

  private

    def verify_admin
      redirect_to root_path unless current_user.admin?
    end

    def menu_item_params
      params.require(:menu_item).permit(:link_text, :link_href, :link_order, :classes, :parent_link_id, :menu_name)
    end
end
