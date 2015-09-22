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

    validate_attributes
    return errors
  end

  def validate_file_type
    return true if !(params[:file_types].present?)

    # Convert file_types to an array if it was passed as a singular string
    if params[:file_types].instance_of? String 
      params[:file_types] = [params[:file_types]]
    end

    unless params[:file_types].all? { |x| valid_ography_types.include? x }
      errors << "Invalid ography types were specified"
      return false
    end

    return true
  end

  def validate_attributes
    # If params[:display_date] is present, ensure that it is something Ruby 
    # understands as a date.
    if params[:display_date].present?
      begin
        Date.iso8601(params[:display_date])
      rescue ArgumentError => e 
        errors << "display_date must be an ISO 8601 compliant date"
      end
    end 

  end

  def valid_ography_types
    %w(personography bibliography otherography
       placeography odd_file orgography)
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
    [:tei, :depositor, :collection_dids]
  end
end
