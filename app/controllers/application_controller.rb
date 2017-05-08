class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper

  def forem_user
    current_user
  end
  helper_method :forem_user

  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout 'blacklight'
  # Please be sure to impelement current_user and user_session. Blacklight depends on
  # these methods in order to perform user specific actions.

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :create_response_object

  def create_temp_file(file)
    fpath = file.path
    fname = file.original_filename

    tmpdir = Rails.root.join("tmp", "#{Time.now.to_i}")
    FileUtils.mkdir_p(tmpdir)
    tmpfile = Rails.root.join(tmpdir, fname)
    FileUtils.mv(fpath, tmpfile)
    return tmpfile.to_s
  end

  def create_temp_file_from_existing(fedora_file, original_file)
    fpath = fedora_file
    fname = original_file

    tmpdir = Rails.root.join("tmp", "#{Time.now.to_i}")
    FileUtils.mkdir_p(tmpdir)
    tmpfile = Rails.root.join(tmpdir, fname)
    FileUtils.cp(fpath, tmpfile)
    return tmpfile.to_s
  end

  def pretty_json(status)
    render json: JSON.pretty_generate(@response), status: status
  end

  def create_response_object
    @response ||= {}
  end

  helper_method :current_user_can?

  def current_user_can?(perm_level, record)
    if current_user
      current_user.can? perm_level, record
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
