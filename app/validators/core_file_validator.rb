class CoreFileValidator < TapasObjectValidator
  # TODO: Delete this special method once params[:node_id] has been changed 
  # to params[:nid], which is a much better name.
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
