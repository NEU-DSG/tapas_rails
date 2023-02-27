class Users::InvitationsController < Devise::InvitationsController
  before_action :verify_admin

  protected

  def verify_admin
    !current_user.admin_at.nil?
  end
end
