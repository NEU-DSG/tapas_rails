require 'spec_helper'

describe CommunityValidator do 
  include ValidatorHelpers

  describe "On POST #upsert" do 
    let(:params) { { title: "valid",
                     members: ["valid"], 
                     did: "111",
                     access: "public",
                     description: "A test community.",
                     action: "upsert",
                     depositor: "101" } }

    it "raises no errors with valid params and an unused did" do 
      expect(validation_errors(params).length).to eq 0 
    end

    context "When creating a new Community it" do 
      it "raises an error with no access param" do 
        expect(validation_errors(params.except :access).length).to eq 1
      end

      it "raises an error with no depositor param" do 
        expect(validation_errors(params.except :depositor).length).to eq 1
      end

      it "raises an error with no did param" do 
        expect(validation_errors(params.except :did).length).to eq 1
      end

      it "raises an error with no title param" do 
        expect(validation_errors(params.except :title).length).to eq 1
      end

      it "raises an error with no members param" do 
        expect(validation_errors(params.except :members).length).to eq 1
      end

      it "raises an error with no description param" do 
        expect(validation_errors(params.except :description).length).to eq 1 
      end
    end

    context "When updating an existing Community it" do 
      before(:all) do 
        @community = Community.create(:did => "111", "depositor" => "test")
      end

      after(:all) { @community.destroy }

      it "requires only the drupal id" do 
        p = { :did => "111", :depositor => "test" }
        expect(validation_errors(p).length).to eq 0 
      end
    end 

    it "raises an error if the did exists but doesn't belong to a Community" do 
      begin
        collection = Collection.new
        collection.did = params[:did]
        collection.depositor = "SYSTEM"
        collection.save!

        expect(validation_errors(params).length).to eq 1
      ensure
        collection.delete if collection.persisted?
      end
    end 

    it "raises no errors if the did exists and belongs to a Community" do 
      begin 
        community = Community.new
        community.did = params[:did]
        community.depositor = "SYSTEM"
        community.save!

        expect(validation_errors(params).length).to eq 0 
      ensure
        community.delete if community.persisted?
      end
    end
  end
end
