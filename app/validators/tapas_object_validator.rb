class TapasObjectValidator

  attr_reader   :params
  attr_accessor :errors

  def initialize(object_params)
    params_hash = object_params || {}
    @params = params_hash.with_indifferent_access
    @errors = []
  end

  def self.validate_params(params)
    self.new(params).validate_params
  end

  def validate_params
    return errors if no_params?
    validate_class_correctness
    validate_required_attributes
    return errors 
  end

  def no_params?
    unless self.params.present? && self.params[:did].present?
      errors << "Request did not specify a did" 
      return true
    end
  end

  # Make sure the object either doesn't exist or is a member of the 
  # requested class.
  def validate_class_correctness
    return true unless Did.exists_by_did? params[:did]

    klass = self.class.to_s[0..-10]
    object = ActiveFedora::Base.where("did_ssim" => params[:did]).first

    if object && !object.instance_of?(klass.constantize)
      errors << "Tried to perform upsert with did #{params[:did]} on object of " + 
                "type #{klass} - did already in use by #{object.class} " + 
                "with id #{object.pid}."
    end
  end

  def validate_required_attributes
    unless Did.exists_by_did? params[:did]
      required_attributes = create_attributes
    else
      required_attributes = [:did]
    end

    required_attributes.each do |attribute|
      unless params[attribute]
        errors << "Object was missing required attribute #{attribute}"
      end
    end
  end
end
