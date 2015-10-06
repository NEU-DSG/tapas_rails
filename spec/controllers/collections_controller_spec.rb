require 'spec_helper'

describe CollectionsController do
  include ValidAuthToken
  include FileHelpers

  it_should_behave_like 'an API enabled controller'

  describe 'DELETE destroy' do 
    after(:each) { ActiveFedora::Base.delete_all }

    it '422s for nonexistant dids' do 
      delete :destroy, { :did => 'not a real did' }
      expect(response.status).to eq 422
    end

    it '422s for dids that do not belong to a Collection' do 
      community = FactoryGirl.create :community
      delete :destroy, { :did => community.did }
      expect(response.status).to eq 422
    end

    it '200s for dids that belong to a Collection and removes the resource' do 
      collection = FactoryGirl.create :collection
      delete :destroy, { :did => collection.did }
      expect(response.status).to eq 200
      expect(Collection.find_by_did collection.did).to be nil 
    end
  end

  describe 'POST upsert' do 
    after(:all) { ActiveFedora::Base.delete_all } 

    it '403s for unauthorized requests' do 
      set_auth_token('bupkes')
      post :upsert, :did => SecureRandom.uuid
      expect(response.status).to eq 403
    end

    it '422s for invalid requests' do 
      post :upsert, :did => SecureRandom.uuid
      expect(response.status).to eq 422 
    end

    it 'returns a 202 and creates the requested collection on a valid request' do 
      Resque.inline = true 
      community = FactoryGirl.create :community

      post_params = { title: 'Collection', 
        access: 'private',  
        did: '8018', 
        project_did: community.did, 
        description: 'This is a test collection',
        depositor: '101',
        thumbnail: Rack::Test::UploadedFile.new(fixture_file('image.jpg')), }

      post :upsert, post_params

      expect(response.status).to eq 202
      collection = Collection.find_by_did '8018'
      expect(collection).not_to be nil 
      expect(collection.depositor).to eq post_params[:depositor]
      Resque.inline = false 
    end
  end
end
