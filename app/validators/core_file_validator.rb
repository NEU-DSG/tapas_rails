class CoreFileValidator
  include TapasObjectValidations

  def self.validate_upsert(params)
    self.new(params).validate_upsert
  end

  def validate_upsert
    validate_class_correctness CoreFile
    return errors if errors.any?

    validate_file_type
    return errors if errors.any?

    validate_required_attributes
    return errors
  end

  def validate_file_type
    if create_or_update == :create && params[:file_type].blank?
      errors << "On create a file_type must be specified"
      return false
    end 

    unless %w(tei_content ography).include? params[:file_type]
      errors << "File type must be one of: 'tei_content', 'ography'"
      return false
    end

    if params[:file_type] == 'tei_content' && create_or_update == :create
      unless params[:collection_dids].present?
        errors << "TEI Content must belong to at least one collection, "\
          "specify collection_dids"
        return false
      end
    elsif params[:file_type] == 'ography' && create_or_update == :create 
      unless params[:project_did].present?
        errors << "Ographies must belong to a project, specify project_did."
        return false
      end
    end

    return true
  end

  # In the case where params that definitely will not be used are passed during
  # an update request, note that instead of returning an error we simply ignore
  # them during processing.  This behavior is useful because it allows the 
  # Drupal system to (if necessary) simply always send requests that comply to
  # the create requirements and trust that the repository will sort things out
  # from there. 
  def update_attrs
    []
  end

  # Note that the existence of correctly set :file_type and :project_did or 
  # :collection_dids params is checked in validate_file_type.
  def create_attrs
    [:tei, :depositor]
  end
end
