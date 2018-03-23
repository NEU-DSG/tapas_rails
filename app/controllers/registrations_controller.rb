class RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters, :only => [:create, :update]
  after_filter :check_membership, :only => [:create, :update]

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :name, :institution_id, :avatar, :bio, :account_type) }
      devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password, :name, :institution_id, :avatar, :remove_avatar, :bio, :account_type) }
    end

    def check_membership
      if resource.check_paid_status
      # user has paid account
      else
        # user does not have paid acount
        if resource.account_type == 'teic'
          # but they think they do
          flash[:error] = "The email you have provided does not match an existing TEI-C Membership. Please check your email and try again."
        else
          # but they already know that
        end
      end
    end
end
