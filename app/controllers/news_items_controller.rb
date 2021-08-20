class NewsItemsController < ApplicationController
  extend ActiveSupport::Concern
  before_filter :verify_admin, :except => [:show, :index]
  before_filter :verify_published, :only => :show

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
    @news_item = NewsItem.friendly.find(params[:id])
    @page_title = @news_item.title
  end

  def edit
    @news_item = NewsItem.friendly.find(params[:id])
    @page_title = @news_item.title
  end

  def update
    @news_item = NewsItem.friendly.find(params[:id])
    @page_title = @news_item.title
    @news_item.update_attributes(news_item_params)
    if @news_item.valid?
      @news_item.save!
      redirect_to @news_item
    else
      flash.now[:error] = @news_item.errors.full_messages.join(",")
      render(:action => :edit)
    end
  end

  def new
    @page_title = "New News Item"
    @news_item = NewsItem.new
    @users =[]
    User.all.each do |u|
      @users << [u.name, u.id]
    end
  end

  def create
    @news_item = NewsItem.new(news_item_params)
    if @news_item.valid?
      @news_item.save!
      redirect_to @news_item
    else
      flash.now[:error] = @news_item.errors.full_messages.join(",")
      render(:action => :new)
    end
  end

  def index
    @page_title = "News Items"
    @news_items = NewsItem.all.where(:publish=>"true")
    if !session[:flash_success].blank?
      flash[:success] = session[:flash_success]
      session.delete(:flash_success)
    end
  end

  def destroy
    @news_item = NewsItem.find(params[:id])
    title = @news_item.title
    redirect_to(:action => :index)
    if @news_item.destroy
      session[:flash_success] = "#{title} has been deleted"
    end
  end

  private

    def verify_admin
      redirect_to root_path unless current_user && current_user.admin?
    end

    def verify_published
      news_item = NewsItem.friendly.find(params[:id])
      render_404("Access denied") unless news_item.publish == "true" || (current_user && current_user.admin?)
    end

    def news_item_params
      params.require(:news_item).permit(:content, :title, :slug, :publish)
    end
end
