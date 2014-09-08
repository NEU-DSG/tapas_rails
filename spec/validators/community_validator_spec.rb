require 'spec_helper'

describe CommunityValidator do 
  include ValidatorHelpers

  before(:all) do 
    @community = FactoryGirl.create(:community)
    @core_file = FactoryGirl.create(:core_file) 
  end

  describe "Parent validation" do
    it "raises an error when the specified parent is nothing" do 
      params = { parent: "invalid:1" } 
      expect(parent_validation_errors(params).length).to eq 1 
    end

    it "raises an error when the specified parent is not a Community" do
      params = { parent: @core_file.pid }
      expect(parent_validation_errors(params).length).to eq 1 
    end

    it "raises no error when the specified parent is a Community" do 
      params = { parent: @community.pid }
      expect(parent_validation_errors(params).length).to eq 0 
    end
  end

  after(:all) { @community.destroy ; @core_file.destroy } 
end