class CollectionValidator
  include TapasObjectValidations

  def self.validate_upsert(params)
    self.new(params).validate_upsert 
  end

  def validate_upsert 
    validate_class_correctness Collection
    return errors if errors.any?

    validate_required_attributes
    return errors if errors.any?

    validate_access_level
    return errors
  end

  def create_attrs
    [:project_did, :title, :description, :depositor, :access]
  end

  def update_attrs
    []
  end
end
