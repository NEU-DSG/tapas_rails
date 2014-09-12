require 'spec_helper'

describe CoreFileValidator do 
  include ValidatorHelpers

  before(:all) do 
    @community  = FactoryGirl.create(:community)
    @collection = FactoryGirl.create(:collection)
  end

  describe "Parent validation" do 
    it "raises an error when the specified parent points at nothing" do 
      params = { parent: "blah:1" }
      expect(parent_validation_errors(params).length).to eq 1
    end

    it "raises an error when the specified parent is not a Collection" do 
      params = { parent: @community.pid } 
      expect(parent_validation_errors(params).length).to eq 1
    end

    it "raises no errors when the parent is a Collection" do
      params = { parent: @collection.pid }  
      expect(parent_validation_errors(params).length).to eq 0
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