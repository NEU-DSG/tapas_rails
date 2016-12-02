class ApplicationController < ActionController::Base
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
    logger.info("inside create_temp_file") 
    logger.warn tmpdir
    logger.warn tmpfile
    logger.warn File.exist?(tmpfile)
    return tmpfile.to_s
  end

  def pretty_json(status)
    render json: JSON.pretty_generate(@response), status: status
  end

  def create_response_object
    @response ||= {}
  end

  # def layout_name
  #   "application"
  # end
end
