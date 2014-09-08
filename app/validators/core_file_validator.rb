class CoreFileValidator
  include TapasObjectValidator

  def self.validate_params(params)
    CoreFileValidator.new(params).validate_params
  end

  def validate_params
    return errors if no_params?
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