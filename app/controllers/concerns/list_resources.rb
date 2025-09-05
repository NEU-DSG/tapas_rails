# Methods common to the Browse pages (and possibly Search)
module ListResources
  extend ActiveSupport::Concern
  
  DEFAULT_SORT = 'updated_at'
  
  # Set up the variables we'll need for constructing a Browse page. This method has the option to
  # include the request parameters in case we need specialized parameters for a particular kind of model.
  def set_up_browse(params = browse_params)
    sort_param = params[:sort]
    # If the user requested a valid sort method, use that. Otherwise, use the default method.
    @sort_method = is_valid_sort_method(sort_param) ? sort_param : DEFAULT_SORT
    # Decide for the user whether to apply the sort method in ascending or descending order.
    @sort_direction = @sort_method == 'updated_at' ? 'DESC' : 'ASC'
  end
  
  def sort_string
    @sort_method+" "+@sort_direction
  end
  
  # Test a requested sort method string against the methods we are prepared to accept. Returns true ONLY 
  # if the request parameter is provided and its lower-cased value matches one of the approved strings.
  def is_valid_sort_method(method = browse_params[:sort])
    allowed_methods = %w(title updated_at)
    !method.blank? && allowed_methods.include?(method.to_s.downcase)
  end
  
  # For requests to a Browse page, permit only the sort parameter.
  def browse_params
    params.permit(:sort)
  end
end