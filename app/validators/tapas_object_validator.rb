class TapasObjectValidator
  attr_reader   :params, :klass
  attr_accessor :errors 

  def initialize(object_params, object_class)
    @params = object_params.with_indifferent_access
    @klass  = object_class
    @errors = []
  end

  def self.validate_params(object_params)
    TapasObjectValidatorService.new(object_params).validate_params 
  end

  def validate_params
    # If the param hash passed in was nonexistant say that 
    # and exit.
    unless params.present?
      errors << "Object had no parameters or did not exist"
      return errors 
    end

    # Check for all required metadata attributes
    required_attributes.each do |attribute| 
      unless params[attribute].present?
        errors << "Object was missing required attribute #{attribute}"
      end
    end

    return errors
  end
end