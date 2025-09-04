module ListResources
  extend ActiveSupport::Concern
  
  #def is_valid_sort_method
    
  #end
  
  def browse_params
    params.permit(:sortBy)
  end
end