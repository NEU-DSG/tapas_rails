class CommunityValidator 
  include TapasObjectValidator

  def self.validate_params(params)
    CommunityValidator.new(params).validate_params
  end

  def validate_params
    #TODO
  end
end