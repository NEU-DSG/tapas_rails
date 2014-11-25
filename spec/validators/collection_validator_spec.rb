require 'spec_helper'

describe CollectionValidator do 
  include ValidatorHelpers

  describe "on POST #create" do 
    let(:params) { { action: "create",
                     nid: "1",
                     project: "333",
                     title:   "Valid",
                     depositor: "123" } }

    it "raises no error with valid params" do 
      expect(validation_errors(params).length).to eq 0
    end

    it "raises an error if nid is already in use" do 
      begin 
        community = Community.new
        community.nid = "1"
        community.save!

        expect(validation_errors(params).length).to eq 1
      ensure
        community.destroy
      end
    end

    it "raises an error with no depositor param" do 
      expect(validation_errors(params.except :depositor).length).to eq 1
    end

    it "raises an error with no nid param" do 
      expect(validation_errors(params.except :nid).length).to eq 1 
    end

    it "raises an error with no project param" do 
      expect(validation_errors(params.except :project).length).to eq 1 
    end

    it "raises an error with no title param" do 
      expect(validation_errors(params.except :title).length).to eq 1 
    end
  end
end
