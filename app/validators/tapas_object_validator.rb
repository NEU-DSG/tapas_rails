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
    validate_required_attributes
    validate_upsert
    return errors 
  end

  def no_params?
    unless self.params.present?
      errors << "Object had no parameters or did not exist" 
      return true
    end
  end

  # Make sure the object either doesn't exist or is a member of the 
  # requested class.
  def validate_upsert
    if params[:action] == 'upsert' 
      return true unless Nid.exists_by_nid? params[:nid]

      klass = self.class.to_s[0..-10]
      object = ActiveFedora::Base.where("nid_ssim" => params[:nid]).first

      if object && !object.instance_of?(klass.constantize)
        errors << "Tried to perform upsert with nid #{params[:nid]} on object of " + 
                  "type #{klass} - nid already in use by #{object.class} " + 
                  "with id #{object.pid}."
      end
    end
  end

  # Make sure the requested object exists if this isn't a create request
  def validate_existence
    case params[:action]
    when "create"
      true
    else
      klass = self.class.to_s[0..-10]
      object = klass.constantize.find_by_nid(params[:nid])
      unless object
        errors << "Tried to operate on #{klass} with nid #{params[:nid]} - no such object."
      end
    end
  end

  def validate_uniqueness
    case params[:action]
    when "create"
      if ActiveFedora::SolrService.query("tapas_nid_ssim:\"#{params[:nid]}\"").any?
        errors << "Object with nid of #{params[:nid]} already exists - aborting."
      end
    else
      return true 
    end
  end

  # Requires that a method 'required_attributes' be defined on the containing
  # class that returns an array of necessary attribute names.
  def validate_required_attributes
    required_attributes.each do |attribute|
      unless params[attribute]
        errors << "Object was missing required attribute #{attribute}"
      end
    end
  end
end
