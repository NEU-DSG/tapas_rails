require 'spec_helper'

describe CoreFileValidator do 
  before(:all) do 
    @community  = FactoryGirl.create(:community)
    @collection = FactoryGirl.create(:collection)
  end

  it "raises a single error only for nil params" do 
    errors = CoreFileValidator.validate_params(nil)
    expect(errors.length).to eq 1 
    expect(errors.first).to eq "Object had no parameters or did not exist"
  end

  describe "Parent validation" do 
    def validate_parent(params) 
      x = CoreFileValidator.new(params)
      x.validate_parent 
      return x.errors 
    end

    it "raises an error when the specified parent points at nothing" do 
      params = { parent: "blah:1" }
      errors = validate_parent(params) 
      expect(errors.length).to eq 1
    end

    it "raises an error when the specified parent is not a Collection" do 
      params = { parent: @community.pid } 
      errors = validate_parent(params)
      expect(errors.length).to eq 1 
    end

    it "raises no errors when the parent is a Collection" do
      params = { parent: @collection.pid }  
      errors = validate_parent(params)
      expect(ActiveFedora::Base.exists?(@collection.pid)).to be true
      expect(errors.length).to eq 0 
    end
  end

  describe "File validation" do
    def validate_files(params)
      x = CoreFileValidator.new(params)
      x.validate_files 
      return x.errors 
    end

    pending "figure out what file validations actually look like" 
  end

  after(:all) { @community.destroy ; @collection.destroy }
end