class CommunityValidator
  include Validations

  def validate_upsert
    required_fields = %i(members depositor access title)
    validate_did_and_create_reqs(Community, required_fields)
    return errors if errors.any?

    validate_all_present_params
    return errors
  end

  def validate_members
    validate_array_of_strings :members
  end

  def validate_depositor
    validate_nonblank_string :depositor
  end

  def validate_access
    validate_access_level
  end

  def validate_title
    validate_nonblank_string :title
  end

  def validate_thumbnail
    validate_file_and_type(:thumbnail, %w(png jpg jpeg))
  end

  def validate_description
    validate_string :description
  end
end
