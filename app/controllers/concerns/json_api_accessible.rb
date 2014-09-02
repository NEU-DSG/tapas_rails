module JsonApiAccessible 
  extend ActiveSupport::Concern 

  included do 
    # Disable CSRF checks for JSON API requests
    skip_before_action :verify_authenticity_token, :if => :json_request?
    # Check for an API token on JSON API requests
    before_action :authenticate_api_request, :if => :json_request?
  end

  private 

  def json_request?
    request.format.json?
  end

  def authenticate_api_request
    
  end
end