class CommunityValidator 
  include TapasObjectValidator

  def self.validate_params(params)
    CommunityValidator.new(params).validate_params
  end

  def validate_params
    return errors if no_params?
    validate_required_attributes
    validate_parent
    return errors
  end

  def required_attributes
    [:title, :parent]
  end

  def validate_parent
    validate_parent_helper([Community])
  end
end