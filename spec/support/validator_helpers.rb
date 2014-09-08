module ValidatorHelpers

  def parent_validation_errors(params)
    x = described_class.new(params)
    x.validate_parent
    return x.errors
  end
end