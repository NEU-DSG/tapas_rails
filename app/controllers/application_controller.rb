# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper

  include Blacklight::Controller
  layout 'application'


  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :create_response_object

  helper_method :current_user_can?


  def create_temp_file(file)
    fpath = file.path
    fname = file.original_filename

    tmpdir = Rails.root.join("tmp", "#{Time.now.to_i}")
    FileUtils.mkdir_p(tmpdir)
    tmpfile = Rails.root.join(tmpdir, fname)
    FileUtils.mv(fpath, tmpfile)
    tmpfile.to_s
  end

  def create_temp_file_from_existing(fedora_file, original_file)
    fpath = fedora_file
    fname = original_file

    tmpdir = Rails.root.join("tmp", "#{Time.now.to_i}")
    FileUtils.mkdir_p(tmpdir)
    tmpfile = Rails.root.join(tmpdir, fname)
    FileUtils.cp(fpath, tmpfile)
    tmpfile.to_s
  end

  def pretty_json(status)
    render json: JSON.pretty_generate(@response), status: status
  end

  def create_response_object
    @response ||= {}
  end

  protected


  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :username,
      :email,
      :password,
      :name,
      :institution_id,
      { image_file: [:file] },
      :bio,
      :account_type
    ])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :email, :password, :password_confirmation, :current_password, :name, :institution_id, { image_file: [:file] }, :remove_avatar, :bio, :account_type])
  end

  def current_user_can?(perm_level, record)
    if record.respond_to? :project
      if record.project
        parent = record.project
      end
    end
    if current_user
      current_user.can? perm_level, record
    elsif current_user && parent
      current_user.can? perm_level, parent
    elsif perm_level != :read
      false
    else
      record.read_groups.include? 'public'
    end
  end

  def render_404(exception, path="")
    logger.error("Rendering 404 page for #{path if path != ""} due to exception: #{exception.inspect} - #{exception.backtrace if exception.respond_to? :backtrace}")
    render 'public/404', :status => 404
  end
end
