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

  def destroy
    object = controller_name.classify.constantize.find_by_did(params[:did])

    if object
      if object.respond_to?(:descendents)
        object.descendents(:models).each { |d| d.delete }
      end

      object.destroy 

      @response[:message] = "Object and descendents deleted" 
      pretty_json(200) and return 
    else
      @response[:message] = "Object of type #{controller_name.classify} with " +
        "did #{params[:did]} not found in the repository." 
      pretty_json(422) and return
    end
  end

  def pretty_json(status)
    render json: JSON.pretty_generate(@response), status: status
  end

  def create_response_object
    @response ||= {}
  end
end
