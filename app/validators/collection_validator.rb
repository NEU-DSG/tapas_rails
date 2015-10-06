class CollectionValidator
  include Validations

  def validate_upsert 
    required = %i(project_did title description depositor access)
    validate_did_and_create_reqs(Collection, required)
    return errors if errors.any?

    validate_all_present_params
    errors
  end

  def validate_project_did
   validate_nonblank_string :project_did

    unless Community.exists_by_did?(params[:project_did])
      errors << 'project with specified did does not exist'
    end
  end

  def validate_title
    validate_nonblank_string :title
  end

  def validate_description
    validate_nonblank_string :description
  end

  def validate_depositor
    validate_nonblank_string :depositor
  end

  def validate_thumbnail
    validate_file_and_type(:thumbnail, %w(png jpeg jpg))
  end

  def validate_access
    validate_access_level
  end
end
