require 'spec_helper'

describe CommunitiesController do
  let(:user)   { FactoryGirl.create(:user) } 
  let(:params) { { email: user.email, token: "test_api_key" } } 

  describe "#POST create" do 
    after(:all) { ActiveFedora::Base.delete_all }

    it "422s for invalid requests" do 
      post :create, params
      expect(response.status).to eq 422
    end

    it "returns a 202 and creates the requested community on a valid request" do
      Resque.inline = true 
      post_params = { title: "a", members: %w(a), nid: "12", description: "blah" }
      post_params = post_params.merge params
      post :create, post_params

      expect(response.status).to eq 202
      community = Community.find(Community.find_by_nid("12").id)
      expect(community.project_members).to eq ["a"]
      Resque.inline = false 
    end
  end

  it_should_behave_like "an API enabled controller"
end
