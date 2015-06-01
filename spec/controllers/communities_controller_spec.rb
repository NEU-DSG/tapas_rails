require 'spec_helper'

describe CommunitiesController do
  let(:user)   { FactoryGirl.create(:user) } 

  describe "#DELETE destroy" do 
    after(:each) { ActiveFedora::Base.delete_all }
    
    let(:params) do 
      { :email => user.email, :token => "test_api_key" }
    end

    it "422s for dids that don't exist" do 
      delete :destroy, params.merge(:did => "doesn't exist")
      expect(response.status).to eq 422
    end

    it "422s for dids that don't belong to a Community" do 
      core_file = CoreFile.create(:did => "123", :depositor => "test")
      delete :destroy, params.merge(:did => core_file.did)
      expect(response.status).to eq 422
    end

    it "200s for successful requests and deletes all descendent objects" do 
      community = Community.create(:did => "123575", :depositor => "test")
      collection = Collection.create(:did => "128654", :depositor => "test") 
      collection.save! ; collection.community = community ; collection.save!
      delete :destroy, params.merge(:did => community.did)
      expect(response.status).to eq 200
      expect(Community.find_by_did community.did).to be nil 
      expect(Collection.find_by_did collection.did).to be nil
    end
  end

  describe "#POST upsert" do 
    before(:all) { Resque.inline = true } 
    after(:each) { ActiveFedora::Base.delete_all } 
    after(:all) { Resque.inline = false } 
    let(:community) { Community.find_by_did params[:did] }

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
