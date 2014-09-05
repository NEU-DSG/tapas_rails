class CollectionValidator
  include TapasObjectValidator

  def self.validate_params(params)
    CollectionValidator.new(params).validate_params 
  end

  def validate_params
    #TODO
  end
end