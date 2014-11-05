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

      # params[:request_body] is simply a wrapper around the form elements that 
      # make up the actual object to be created, and the specifics of it are 
      # handled by each <Klass>CreatorService object.
      request_body = params[:request_body]
      Drs::Application::Queue.push(TapasObjectCreationJob.new(request_body, c))
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

    # Strip api_key and validation email so they're never 
    # displayed/used past this point
    params.except!(:token, :email)
  end

  # Validates that the metadata passed in is valid 
  def validate_creation_params
    validator = "#{controller_name.classify}Validator".constantize
    errors    = validator.validate_params(params)

    if errors.present?
      # Build a json error response with all errors and the original 
      # params of the request as interpreted by the server
      # Ensure api_key is NOT displayed by this
      msg = {
        message: "Resource creation failed.  Invalid parameters! " + 
                 "Note that original_object_parameters deliberately " +
                 "does not display your api key.",
        errors:  errors,

        original_object_parameters: original_post_params
      }
      render json: JSON.pretty_generate(msg), status: 422
    end
  end

  def original_post_params
    pcopy = params
    # Returns a sanitized json display of original post params

    # Remove controller and action hash elems 
    pcopy.except!(:controller, :action)

    # If original request involved a file, clean up what we display
    # back to the end user.
    if pcopy[:file]
      pcopy[:file] = pcopy[:file].as_json.except!("tempfile")
    end

    return pcopy
  end
end