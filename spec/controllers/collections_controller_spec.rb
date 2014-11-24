require 'spec_helper'

describe CollectionsController do
  let(:user) { FactoryGirl.create(:user) } 
  let(:params) { { email: user.email, token: "test_api_key" } } 

  it_should_behave_like "an API enabled controller"

  describe "POST #create" do 
    after(:all) { ActiveFedora::Base.delete_all }

    it "422s for invalid requests" do 
      post :create, params
      expect(response.status).to eq 422
    end

    it "returns a 202 and creates the requested collection on a valid request" do 
      Resque.inline = true 
      post_params = { title: "Collection", nid: "8018", project: "invalid" }
      post_params = post_params.merge params
      post :create, post_params

      expect(response.status).to eq 202
      expect(Collection.find_by_nid("8018")).not_to be nil 
      Resque.inline = false
    end
  end
end
