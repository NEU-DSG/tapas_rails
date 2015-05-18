require 'spec_helper'

describe CollectionValidator do 
  include ValidatorHelpers

  describe "on POST #upsert" do 
    let(:params) { { action: "upsert",
                     did: "1",
                     project: "333",
                     access: "public",
                     title:   "Valid",
                     depositor: "123" } }

    it "raises no error with valid params" do 
      expect(validation_errors(params).length).to eq 0
    end

    it "raises no error if did is already in use by a Collection" do 
      begin 
        collection = Collection.new
        collection.did = params[:did]
        collection.depositor = params[:depositor]
        collection.save!

        expect(validation_errors(params).length).to eq 0 
      ensure
        collection.destroy if collection.persisted?
      end
    end

    it "raises an error if did is already in use by a non-Collection" do 
      begin 
        community = Community.new
        community.did = "1"
        community.save!

        expect(validation_errors(params).length).to eq 1
      ensure
        community.destroy
      end
    end

    it "raises an error with no access param" do 
      expect(validation_errors(params.except :access).length).to eq 1 
    end

    it "raises an error with no depositor param" do 
      expect(validation_errors(params.except :depositor).length).to eq 1
    end

    it "raises an error with no did param" do 
      expect(validation_errors(params.except :did).length).to eq 1 
    end

    it "raises an error with no project param" do 
      expect(validation_errors(params.except :project).length).to eq 1 
    end

    it "raises an error with no title param" do 
      expect(validation_errors(params.except :title).length).to eq 1 
    end
  end
end
