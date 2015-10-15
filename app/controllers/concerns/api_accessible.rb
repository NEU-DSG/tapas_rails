module ApiAccessible 
  extend ActiveSupport::Concern 

  included do 
    # Disable CSRF protection...
    skip_before_action :verify_authenticity_token

    # But enforce credential checks on each and every request.
    # Note that this and the csrf disable up top will have to be 
    # reworked once tapas_rails is the actual frontend for tapas.
    before_action :authenticate

    # This is necessary because of apparent limitations in Drupal.
    # Ensure that numerically keyed hashes are transformed into 
    # arrays before passing them further down the chain.
    before_action :associative_array_to_array

    before_action :load_resource_by_did, :except => [:upsert]

    before_action :validate_upsert, :only => [:upsert]
  end

  def destroy
    resource = instance_variable_get("@#{controller_path.classify.underscore}")

    if resource.destroy
      @response[:message] = 'Resource successfully deleted'
      pretty_json(200) and return 
    end
  end
      

  private

  def load_resource_by_did
    model  = controller_path.classify.constantize
    object = model.find_by_did(params[:did]) 

    if object
      instance_variable_set("@#{model.to_s.underscore}", object)
    else
      @response[:message] = "Resource not found"
      pretty_json(404) and return
    end
  end

  def authenticate
    authenticate_api_request || render_403
  end

  def authenticate_api_request
    authenticate_with_http_token do |token, options| 
      hash = Digest::SHA512.hexdigest token
      return User.exists?(:encrypted_api_key => hash)
    end
  end

  def render_403
    render(:json => "Access denied", :status => 403) and return 
  end

  def associative_array_to_array
    params.each do |key, value|
      if value.is_a?(Hash) && value.keys.all? { |k| is_numeric?(k) }
        params[key] = value.values 
      end
    end
  end

  # Validate the params associated with update and create API requests
  def validate_upsert
    puts 'running upsert validate'
    validator = "#{controller_name.classify}Validator".constantize
    errors    = validator.validate_upsert(params)

    if errors.present?
      # Build a json error response with all errors and the original 
      # params of the request as interpreted by the server
      msg = {
        message: "Resource creation failed.  Invalid parameters!",
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
    if pcopy[:tei]
      pcopy[:tei] = pcopy[:tei].as_json.except!('tempfile')
    end

    if pcopy[:support_files]
      pcopy[:support_files] = pcopy[:support_files].as_json.except!('tempfile')
    end

    return pcopy
  end

  def is_numeric?(str)
    /\A[-+]?\d+\z/ === str
  end
end
