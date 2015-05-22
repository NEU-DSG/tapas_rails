require 'spec_helper'

describe CollectionValidator do 
  include ValidatorHelpers

  describe "on POST #upsert" do 
    let(:params) { { action: "upsert",
                     did: "1",
                     project_did: "333",
                     description: "A Test Collection",
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

    context "When we are creating a new collection" do 
      it "raises an error with no access param" do 
        expect(validation_errors(params.except :access).length).to eq 1 
      end

      it "raises an error with no depositor param" do 
        expect(validation_errors(params.except :depositor).length).to eq 1
      end

      it "raises an error with no did param" do 
        expect(validation_errors(params.except :did).length).to eq 1 
      end

      it "raises an error with no description param" do 
        expect(validation_errors(params.except :description).length).to eq 1 
      end

      it "raises an error with no project_did param" do 
        expect(validation_errors(params.except :project_did).length).to eq 1 
      end

      it "raises an error with no title param" do 
        expect(validation_errors(params.except :title).length).to eq 1 
      end
    end

    context "When we are updating an existing collection" do 
      before(:all) do
        @collection = Collection.create(:did => "1", :depositor => "Test")
      end

      after(:all) { @collection.destroy }

      it "requires only the Drupal ID of the collection" do 
        p = { :action => "upsert", :did => params[:did] }
        expect(validation_errors(p).length).to eq 0
      end
    end
  end
end
