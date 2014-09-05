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
    email   = params[:email]
    api_key = params[:token]

    render_json_403 = Proc.new do 
      render(json: { message: "Access denied" }, status: 403) and return 
    end

    if User.where(:email => email).any?
      user = User.where(:email => email).first
      render_json_403.call and return unless (user.api_key == api_key)
    else
      render_json_403.call and return
    end
  end
end