module ApiAccessible 
  extend ActiveSupport::Concern 

  included do 
    # Disable CSRF protection...
    skip_before_action :verify_authenticity_token

    # But enforce credential checks on each and every request.
    # Note that this and the csrf disable up top will have to be 
    # reworked once tapas_rails is the actual frontend for tapas.
    before_action :authenticate_api_request

    before_action :validate_creation_params, only: [:create]

    def create
      c = controller_name.classify.to_s
      object = params[:object]
      Drs::Application::Queue.push(TapasObjectCreationJob.new(object, c))
    end
  end

  private

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

  # Validates that the metadata passed in is valid 
  def validate_creation_params
    validator = "#{controller_name.classify}Validator".constantize
    errors    = validator.validate_params(params[:object])

    if errors.present?
      # Build a json error response with all errors and the original 
      # params of the request as interpreted by the server
      # Ensure api_key is NOT displayed by this
      msg = {
        message: "Resource creation failed.  Invalid parameters!",
        errors:  errors,

        original_object_parameters: params[:object]
      }
      render json: msg, status: 422
    end
  end
end