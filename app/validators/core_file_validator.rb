class CoreFileValidator
  include TapasObjectValidator

  def self.validate_params(params)
    CoreFileValidator.new(params).validate_params
  end

  def validate_params
    return errors if no_params?
    validate_required_attributes
    return errors
  end

  def required_attributes
    [:file, :depositor, :collection]
  end
end