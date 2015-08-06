class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller 
   include Blacklight::Controller
  # Please be sure to impelement current_user and user_session. Blacklight depends on 
  # these methods in order to perform user specific actions. 

  # Uncomment this once there is a frontend. 
  # layout 'blacklight'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :create_response_object

  def create_temp_file(file)
    fpath = file.path
    fname = file.original_filename 
    
    tmp = Rails.root.join('tmp', "#{SecureRandom.hex}-#{fname}").to_s 
    FileUtils.mv(fpath, tmp) 
    return tmp
  end

  def pretty_json(status)
    render json: JSON.pretty_generate(@response), status: status
  end

  def create_response_object
    @response ||= {}
  end
end
