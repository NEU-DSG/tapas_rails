# Methods common to pages that list sorted resources (Browse, Search)
module Sortable
  extend ActiveSupport::Concern
  
  private
  
  SORT_OPTIONS = [
    ["date created", 'created_at'], 
    ["date updated", 'updated_at'], 
    ['title', 'title']
  ].freeze
  
  DEFAULT_SORT = 'updated_at'
  
  # Gather information about sorting for this resource type.
  def set_sorting(add_sort_options = [])
    @sort_options = SORT_OPTIONS.dup
    if ( add_sort_options.present? )
      @sort_options.concat(add_sort_options)
    end
    
    @sort_method = sort_method
    @sort_direction = sort_direction
  end
  
  # Choose a sort order direction.
  def sort_direction(order_param = browse_params[:sort_direction])
    # If the user requested a valid sort direction, use the uppercased value.
    is_valid_sort_direction(order_param) ? order_param.to_s.upcase
      # If there isn't a given sort order but the method is "updated_at", sort the newest first.
      : @sort_method == 'updated_at' ? 'DESC'
        # Otherwise, use ascending order.
        : 'ASC'
  end
  
  # Choose a sort method.
  def sort_method(sort_param = browse_params[:sort])
    # If the user requested a valid sort method, use that. Otherwise, use the default method.
    is_valid_sort_method(sort_param) ? sort_param : DEFAULT_SORT
  end
  
  def sort_string
    sort_method+" "+sort_direction
  end
  
  def allowed_sort_methods
    @sort_options.map{ |option| option.last }
  end
  
  # Test a requested sort method string against the methods we are prepared to accept. Returns true ONLY 
  # if the request parameter is provided and its lower-cased value matches one of the approved strings.
  def is_valid_sort_method(sort_method = browse_params[:sort])
    sort_method.present? && allowed_sort_methods.include?(sort_method.to_s.downcase)
  end
  
  # Test that a requested sort direction is provided AND is either "ASC" or "DESC" (case insensitive).
  def is_valid_sort_direction(direction = browse_params[:sort_direction])
    allowed_order = %w(ASC DESC)
    direction.present? && allowed_order.include?(direction.to_s.upcase)
  end
  
  # For requests to a Browse page, permit only the sorting parameters.
  def browse_params
    params.permit(:sort, :sort_direction)
  end
end