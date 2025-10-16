# Methods common to the Browse pages (and possibly Search)
module ListResources
  extend ActiveSupport::Concern
  
  DEFAULT_SORT = 'updated_at'
  
  # Set up the variables we'll need for constructing a Browse page. This method has the option to
  # include the request parameters in case we need specialized parameters for a particular kind of model.
  def set_up_browse(params = browse_params)
    # If the user requested a valid sort method, use that. Otherwise, use the default method.
    sort_param = params[:sort]
    @sort_method = is_valid_sort_method(sort_param) ? sort_param : DEFAULT_SORT
    
    # If the user requested a valid sort direction, use that.
    order_param = params[:sort_direction]
    @sort_direction = 
      is_valid_sort_direction(order_param) ? order_param.to_s.upcase :
      # If there isn't a given sort order but the method is "updated_at", sort the newest first.
      # Otherwise, use ascending order.
      @sort_method == 'updated_at' ? 'DESC' : 'ASC'
  end
  
  def sort_string
    @sort_method+" "+@sort_direction
  end
  
  # Test a requested sort method string against the methods we are prepared to accept. Returns true ONLY 
  # if the request parameter is provided and its lower-cased value matches one of the approved strings.
  def is_valid_sort_method(sort_method = browse_params[:sort])
    allowed_methods = %w(created_at title updated_at)
    sort_method.present? && allowed_methods.include?(sort_method.to_s.downcase)
  end
  
  def is_valid_sort_direction(direction = browse_params[:sort_direction])
    allowed_order = %w(ASC DESC)
    direction.present? && allowed_order.include?(direction.to_s.upcase)
  end
  
  # For requests to a Browse page, permit only the sorting parameters.
  def browse_params
    params.permit(:sort, :sort_direction)
  end
end