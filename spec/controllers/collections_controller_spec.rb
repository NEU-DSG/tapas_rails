require 'spec_helper'

describe CollectionsController do
  let(:user) { FactoryGirl.create(:user) } 
  let(:params) { { email: user.email, token: "test_api_key" } } 

  it_should_behave_like "an API enabled controller"

  describe "POST #upsert" do 
    after(:all) { ActiveFedora::Base.delete_all } 

    it "403s for unauthorized requests" do 
      post :upsert, params.except(:token)
      expect(response.status).to eq 403
    end

    it "422s for invalid requests" do 
      post :upsert, params 
      expect(response.status).to eq 422 
    end

    it "returns a 202 and creates the requested collection on a valid request" do 
      Resque.inline = true 
      post_params = { title: "Collection", 
        access: "private",  
        did: "8018", 
        project: "invalid", 
        depositor: "101" }
      post_params = post_params.merge params
      post :upsert, post_params

      expect(response.status).to eq 202
      expect(Collection.find_by_did("8018")).not_to be nil 
      Resque.inline = false 
    end
  end
end
