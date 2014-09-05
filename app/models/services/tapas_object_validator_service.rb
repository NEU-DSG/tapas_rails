class TapasObjectValidator
  attr_reader   :params
  attr_accessor :errors 

  def initialize(object_params)
    @params = object_params.with_indifferent_access
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
  end
end