module ValidatorHelpers

  def validation_errors(params)
    return described_class.validate_params(params)
  end

  def parent_validation_errors(params)
    x = described_class.new(params)
    x.validate_parent
    return x.errors
  end
end
