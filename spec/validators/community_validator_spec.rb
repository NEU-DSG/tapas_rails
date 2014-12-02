require 'spec_helper'

describe CommunityValidator do 
  include ValidatorHelpers

  describe "On POST #create" do 
    let(:params) { { title: "valid",
                     members: ["valid"], 
                     nid: "111",
                     action: "create",
                     depositor: "101" } }

    it "raises no error with valid params" do 
      expect(validation_errors(params).length).to eq 0
    end

    it "raises an error if the specified nid is already in use" do 
      begin 
        collection = Collection.new
        collection.nid = "111"
        collection.depositor = "0000000"
        collection.save!

        expect(validation_errors(params).length).to eq 1
      ensure
        collection.delete if collection.persisted?
      end
    end

    it "raises an error with no depositor param" do 
      expect(validation_errors(params.except :depositor).length).to eq 1
    end

    it "raises an error with no nid param" do 
      expect(validation_errors(params.except :nid).length).to eq 1
    end

    it "raises an error with no title param" do 
      expect(validation_errors(params.except :title).length).to eq 1
    end

    it "raises an error with no members param" do 
      expect(validation_errors(params.except :members).length).to eq 1
    end
  end

  describe "On PUT #update" do 
    let(:params) { { action: "nid_update", nid: "111" } } 

    it "raises an error if the nid doesn't exist" do 
      expect(validation_errors(params).length).to eq 1
    end

    it "raises an error if the nid exists but doesn't belong to a Community" do 
      begin
        collection = Collection.new
        collection.nid = params[:nid]
        collection.depositor = "SYSTEM"
        collection.save!

        expect(validation_errors(params).length).to eq 1
      ensure
        collection.delete if collection.persisted?
      end
    end 

    it "raises no errors if the nid exists and belongs to a Community" do 
      begin 
        community = Community.new
        community.nid = params[:nid]
        community.depositor = "SYSTEM"
        community.save!

        expect(validation_errors(params).length).to eq 0 
      ensure
        community.delete if community.persisted?
      end
    end
  end
end
