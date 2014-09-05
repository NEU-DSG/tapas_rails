class CoreFileValidator
  include TapasObjectValidator

  def self.validate_params(params)
    CoreFileValidator.new(params).validate_params
  end

  def validate_params
    unless params.present?
      errors << "Object had no parameters or did not exist" 
      return errors 
    end

    validate_required_attributes
    validate_parent
    validate_files
    return errors
  end

  def required_attributes
    [:title, :files, :parent]
  end

  def validate_parent
    validate_parent_helper([Collection])
  end

  def validate_files
    #TODO
  end
end