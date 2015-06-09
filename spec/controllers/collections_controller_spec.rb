require 'spec_helper'

describe CollectionsController do
  it_should_behave_like "an API enabled controller"

  before(:each) do 
    # Instatiate the test user before we try to use his credentials
    FactoryGirl.create(:user)

    t = ActionController::HttpAuthentication::Token.
      encode_credentials('test_api_key')
    request.env['HTTP_AUTHORIZATION'] = t
  end

  describe "DELETE destroy" do 
    after(:each) { ActiveFedora::Base.delete_all }

    it "422s for nonexistant dids" do 
      delete :destroy, { :did => "not a real did" }
      expect(response.status).to eq 422
    end

    it "422s for dids that don't belong to a Collection" do 
      begin
        community = Community.create(:did => "115", :depositor => "test")
        delete :destroy, { :did => community.did }
        expect(response.status).to eq 422
      ensure
        community.delete if community.persisted?
      end
    end

    it "200s for dids that belong to a Collection and removes the resource" do 
      collection = Collection.create(:did => "938401", :depositor => "test")
      delete :destroy, { :did => collection.did }
      expect(response.status).to eq 200
      expect(Collection.find_by_did collection.did).to be nil 
    end
  end

  describe "POST upsert" do 
    after(:all) { ActiveFedora::Base.delete_all } 

    it "403s for unauthorized requests" do 
      request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::
        Token.encode_credentials('not_an_api_key')
      post :upsert
      expect(response.status).to eq 403
    end

    it "422s for invalid requests" do 
      post :upsert, {}
      expect(response.status).to eq 422 
    end

    it "returns a 202 and creates the requested collection on a valid request" do 
      Resque.inline = true 
      post_params = { title: "Collection", 
        access: "private",  
        did: "8018", 
        project_did: "invalid", 
        description: "This is a test collection",
        depositor: "101" }

      post :upsert, post_params

      expect(response.status).to eq 202
      expect(Collection.find_by_did("8018")).not_to be nil 
      Resque.inline = false 
    end
  end
end
