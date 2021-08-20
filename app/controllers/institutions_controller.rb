class InstitutionsController < ApplicationController
  extend ActiveSupport::Concern
  before_action :verify_admin, :except => [:show, :index]

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
    @institution = Institution.find(params[:id])
    @page_title = @institution.name
    count = ActiveFedora::SolrService.count("institutions_ssim:\"#{@institution.id}\"")
    @communities = ActiveFedora::SolrService.query("institutions_ssim:\"#{@institution.id}\"", rows: count)
  end

  def edit
    @institution = Institution.find(params[:id])
    @page_title = @institution.name
  end

  def update
    @institution = Institution.find(params[:id])
    @page_title = @institution.name
    @institution.update_attributes(institution_params)
    if @institution.valid?
      @institution.save!
      redirect_to @institution
    else
      flash.now[:error] = @institution.errors.full_messages.join(",")
      render(:action => :edit)
    end
  end

  def new
    @page_title = "New Institution"
    @institution = Institution.new
    @users =[]
    User.all.each do |u|
      @users << [u.name, u.id]
    end
  end

  def create
    @institution = Institution.new(institution_params)
    if @institution.valid?
      @institution.save!
      redirect_to @institution
    else
      flash.now[:error] = @institution.errors.full_messages.join(",")
      render(:action => :new)
    end
  end

  def index
    @page_title = "Institutions"
    @institutions = Institution.all
    if !session[:flash_success].blank?
      flash[:success] = session[:flash_success]
      session.delete(:flash_success)
    end
  end

  def destroy
    @institution = Institution.find(params[:id])
    name = @institution.name
    redirect_to(:action => :index)
    if @institution.destroy
      session[:flash_success] = "#{name} has been deleted"
    end
  end

  private

    def verify_admin
      redirect_to root_path unless current_user && current_user.admin?
    end

    def institution_params
      params.require(:institution).permit(:name, :description, :image, :address, :latitude, :longitude, :url)
    end
end
