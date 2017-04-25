class PagesController < ApplicationController
  def show
    @page = Page.friendly.find(params[:id])
    render_404(ActiveRecord::RecordNotFound::Error) if @page.nil?
  end

  def edit
    @page = Page.friendly.find(params[:id])
    render_404(ActiveRecord::RecordNotFound::Error) if @page.nil?
  end

  def new
    @page = Page.new
  end

  def create
    @page = Page.new(params.require(:page).permit(:content, :title, :slug))
    @page.save!
    redirect_to @page
  end
end
