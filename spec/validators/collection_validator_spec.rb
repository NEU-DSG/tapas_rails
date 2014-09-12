require 'spec_helper'

describe CollectionValidator do 
  include ValidatorHelpers

  before(:all) do 
    @core_file  = FactoryGirl.create(:core_file)
    @collection = FactoryGirl.create(:collection)
    @community  = FactoryGirl.create(:community) 
  end

  describe "Parent validation" do 
    it "raises an error when the specified parent pid does not exist" do 
      params = { parent: "x:1" } 
      expect(parent_validation_errors(params).length).to eq 1 
    end

    it "raises an error when the specified parent is a CoreFile" do 
      params = { parent: @core_file.pid } 
      expect(parent_validation_errors(params).length).to eq 1 
    end

    it "raises no error when the specified parent is a Community" do 
      params = { parent: @community.pid } 
      expect(parent_validation_errors(params).length).to eq 0 
    end

    it "raises no error when the specified parent is a Collection" do 
      params = { parent: @collection.pid } 
      expect(parent_validation_errors(params).length).to eq 0
    end
  end

  after(:all) { @core_file.destroy ; @collection.destroy ; @community.destroy }
end
