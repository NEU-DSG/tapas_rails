module ListResources
  extend ActiveSupport::Concern
  
  def is_valid_sort_method(method = browse_params[:sort])
    allowed_methods = %w(title updated_at)
    !method.blank? && allowed_methods.include?(method.to_s.downcase)
  end
  
  def browse_params
    params.permit(:sort)
  end
end