class AdminController < ApplicationController

  before_action :authenticate_user!
  before_action :verify_admin

  def index
    @page_title = "Admin Home"
  end

  private

    def verify_admin
      redirect_to root_path unless current_user && current_user.admin?
    end

end
