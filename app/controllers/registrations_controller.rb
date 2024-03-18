class RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, :only => [:create, :update]
  # cch03052024: disabled as membership feature is not supported in new TAPAS
  # after_filter :check_membership, :only => [:create, :update]

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :name, :institution_id, :avatar, :bio, :account_type) }
      devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password, :name, :institution_id, :avatar, :remove_avatar, :bio, :account_type) }
    end

    # def check_membership
    #   if resource.check_paid_status
    #   # user has paid account
    #   else
    #     # user does not have paid acount
    #     if resource.account_type == 'teic'
    #       # but they think they do
    #       flash[:error] = "We're really sorry, but we can't find a record of your TEI-C membership. Please verify that you used the same email address for TAPAS and for your TEI-C membership, and try again, or change to a free account. You can link this account with your TEI-C membership later on. Please see <a href=\"\">membership info</a> for more information and <a href=\"mailto:info@tapasproject.org\">contact us</a> with any questions or for help with this process. Thank you so much for your interest in TAPAS."
    #     elsif resource.account_type == "teic_inst"
    #       flash[:error] = "We're really sorry, but we can't verify your TEI-C membership based on the email address you listed. Please verify that you used the same email address for TAPAS and for your institution's TEI-C membership bundle, and try again, or change to a free account. You can then contact your institution's TEI membership contact and ask to be added to your institution's TEI membership bundle (using the email address you used to sign up for TAPAS). Please see <a href=\"\">membership info</a> for more information and <a href=\"mailto:info@tapasproject.org\">contact us</a> with any questions or for help with this process. Thank you so much for your interest in TAPAS."
    #     else
    #       # but they already know that
    #     end
    #   end
    # end
end
