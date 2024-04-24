# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]


  # def index
  #   @users = User.all
  # end

  def new
    super
  end

  def edit
    @institutions = Institution.select(:name, :id)

    super
  end

  def update
    @user = User.find(params[:id])
    @user.update(user_params)
    flash[:notice] = "#{@user.email} was updated"

    redirect_to edit_user_path(@user)
  end

  def destroy
    user = User.find(params[:id])

    if user.discarded?
      user.delete
    else
      user.discard
    end

    redirect_to users_path
  end

  def create
    build_resource

    if resource.save
      set_flash_message :notice, :signed_up
      root_path
    else
      super
    end
  end

  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  def cancel
    super
  end

  protected

  def after_sign_up_path_for(resource)
    root_path
  end

  def user_params
    params.require(:user).permit(
    :id,
      :name,
      :email,
      :institution_id,
      :admin
    )
  end

  # # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [])
  # end
  #
  # # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [])
  # end

  # The path used after sign up.

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   welcome_path
  # end
end
