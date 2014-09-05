module ApiAccessible 
  extend ActiveSupport::Concern 

  included do 
    # Disable CSRF protection...
    skip_before_action :verify_authenticity_token

    # But enforce credential checks on each and every request.
    before_action :authenticate_api_request
  end

  private

  def auth_info_present?
    params[:email].present? && params[:token].present?
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