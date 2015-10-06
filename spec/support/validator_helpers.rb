module ValidatorHelpers
  extend ActiveSupport::Concern

  included do 
    before(:each) { @errors = nil }
  end

  def validate(params)
    @errors = described_class.validate_upsert(params)
  end

  def it_raises_a_single_error(string)
    expect(@errors.length).to eq 1 
    expect(@errors.first).to include string
  end
end
