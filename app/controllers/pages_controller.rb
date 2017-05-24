class PagesController < ApplicationController
  extend ActiveSupport::Concern
  before_filter :verify_admin, :except => :show
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
    @page = Page.friendly.find(params[:id])
    @page_title = @page.title
  end

  def edit
    @page = Page.friendly.find(params[:id])
    @page_title = @page.title
  end

  def update
    @page = Page.friendly.find(params[:id])
    @page_title = @page.title
    @page.update_attributes(page_params)
    if @page.valid?
      @page.save!
      redirect_to @page
    else
      flash.now[:error] = @page.errors.full_messages.join(",")
      render(:action => :edit)
    end
  end

  def new
    @page_title = "New Page"
    @page = Page.new
  end

  def create
    @page = Page.new(page_params)
    if @page.valid?
      @page.save!
      redirect_to @page
    else
      flash.now[:error] = @page.errors.full_messages.join(",")
      render(:action => :new)
    end
  end

  def index
    @page_title = "Pages"
    @pages = Page.all
  end

  private

    def verify_admin
      redirect_to root_path unless current_user.admin?
    end

    def verify_published
      page = Page.friendly.find(params[:id])
      render_404("Access denied") unless page.publish == "true" || (current_user && current_user.admin?)
    end

    def page_params
      params.require(:page).permit(:content, :title, :slug, :bootsy_image_gallery_id, :publish)
    end
end
