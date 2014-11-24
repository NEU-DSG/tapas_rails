class CollectionValidator
  include TapasObjectValidator

  def self.validate_params(params)
    CollectionValidator.new(params).validate_params 
  end

  def validate_params
    return errors if no_params?
    validate_required_attributes
    return errors 
  end

  def required_attributes
    case params["action"]
    when "create"
      [:nid, :project, :title]
    end
  end
end
