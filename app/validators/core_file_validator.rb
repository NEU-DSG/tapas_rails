class CoreFileValidator
  include TapasObjectValidator

  def self.validate_params(params)
    CoreFileValidator.new(params).validate_params
  end

  def validate_params
    return errors if no_params?
    validate_required_attributes
    validate_uniqueness
    return errors
  end

  def validate_uniqueness 
    if (params[:action] == "create") && CoreFile.find_by_nid(params[:node_id])
      errors << "Core File with nid #{params[:node_id]} already exists, aborting create"
    end
  end 

  def required_attributes
    case params[:action]
    when "create"
      [:depositor, :node_id, :collection_id, :file]
    when "update"
      []
    end
  end
end
