class CommunityValidator
  include TapasObjectValidations

  def self.validate_upsert(params)
    self.new(params).validate_upsert
  end

  def validate_upsert
    validate_class_correctness Community
    return errors if errors.any?

    validate_required_attributes
    return errors
  end

  def update_attrs
    []
  end

  def create_attrs
    [:members, :depositor, :access, :title, :description]
  end
end
