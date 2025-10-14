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
    if is_valid_sort_direction(order_param)
      @sort_direction = order_param
    # If the user didn't specify and the sort method is "updated_at", use descending order (most recent first).
    elsif @sort_method == 'updated_at'
      @sort_direction = 'DESC'
    # Otherwise, use ascending order.
    else
      @sort_direction = 'ASC'
    end
  end
  
  def sort_string
    @sort_method+" "+@sort_direction
  end
  
  # Test a requested sort method string against the methods we are prepared to accept. Returns true ONLY 
  # if the request parameter is provided and its lower-cased value matches one of the approved strings.
  def is_valid_sort_method(sort_method = browse_params[:sort])
    allowed_methods = %w(title updated_at)
    !sort_method.blank? && allowed_methods.include?(sort_method.to_s.downcase)
  end
  
  def is_valid_sort_direction(direction = browse_params[:sort_direction])
    allowed_order = %w(desc asc)
    !direction.blank? && allowed_order.include?(direction.to_s.downcase)
  end
  
  # For requests to a Browse page, permit only the sorting parameters.
  def browse_params
    params.permit(:sort, :sort_direction)
  end
end