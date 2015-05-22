require 'spec_helper'

describe CommunitiesController do
  let(:user)   { FactoryGirl.create(:user) } 

  describe "#POST upsert" do 
    before(:all) { Resque.inline = true } 
    after(:each) { ActiveFedora::Base.delete_all } 
    after(:all) { Resque.inline = false } 

    let(:params) do 
      { :email => user.email, 
        :token => "test_api_key",
        :title => "Test Community",
        :depositor => "000000000",
        :description => "This is a test community.",
        :members => %w(1 2 3),
        :access => "public",
        :did => "12",
      } 
    end
    let(:community) { Community.find_by_did params[:did] }

    it "422s for invalid requests" do 
      post :upsert, params.except(:depositor)
      expect(response.status).to eq 422
    end

    it "returns a 202 and creates community on requests with new dids." do 
      post :upsert, params

      expect(response.status).to eq 202
      expect(community.depositor).to eq params[:depositor]
    end

    it "returns a 202 and updates the requested community if it exists" do 
      community_old = Community.new
      community_old.mods.title = "Test Community"
      community_old.did = params[:did] 
      community_old.depositor = "System" 
      community_old.project_members = ["303"]
      community_old.save!

      post :upsert, params 
      expect(response.status).to eq 202 
      expect(community.depositor).to eq params[:depositor]
      expect(community.project_members).to eq ["1", "2", "3"]
    end 
  end

  it_should_behave_like "an API enabled controller"
end
