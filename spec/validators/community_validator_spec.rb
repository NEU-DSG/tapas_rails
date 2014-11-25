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
end
