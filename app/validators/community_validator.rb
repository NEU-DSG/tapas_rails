class CommunityValidator 
  include TapasObjectValidator

  def self.validate_params(params)
    CommunityValidator.new(params).validate_params
  end

  def validate_params
    return errors if no_params?
    validate_required_attributes
    return errors
  end

  def required_attributes
    case params[:action]
    when "create"
      [:nid, :title, :description, :users]
    when "update"
      #TODO
    end
  end
end
