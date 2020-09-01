require 'spec_helper'

describe CollectionsController do
  include ValidAuthToken
  include FileHelpers

  it_should_behave_like 'an API enabled controller'

  # describe 'DELETE destroy' do
  #   after(:each) { ActiveFedora::Base.delete_all }
  #
  #   it '404s for nonexistant dids' do
  #     delete :destroy, { :did => 'not a real did' }
  #     expect(response.status).to eq 404
  #   end
  #
  #   it '404s for dids that do not belong to a Collection' do
  #     community = FactoryBot.create :community
  #     delete :destroy, { :did => community.did }
  #     expect(response.status).to eq 404
  #   end
  #
  #   it '200s for dids that belong to a Collection and removes the resource' do
  #     collection = FactoryBot.create :collection
  #     delete :destroy, { :did => collection.did }
  #     expect(response.status).to eq 200
  #     expect(Collection.find_by_did collection.did).to be nil
  #   end
  # end

  describe 'POST upsert' do
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
      community = FactoryBot.create :community

      post_params = { title: 'Collection',
        access: 'private',
        did: '8018',
        community: community.pid,
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

  # Adding new tests for Collections controller

  # Testing the new function defined in Collections Controller
  describe 'get #new' do

    # Purpose statement
    it 'should create a collection object' do

      # Calling create function
      get :new

      # Testing the object creation parameters of collections
      #binding.pry

      # Checking whether the new object is of class type Collection
      expect(assigns(:collection)).to be_a_new(Collection)
    end
  end

  # Testing the create function in the Collections Controller
  describe 'post #create' do


    before(:all) {

      Resque.inline = true
      @user = FactoryBot.create(:user)
      # Creation of Community object before all test begin which is used later for creating a Collection object
      @community = Community.new(title:"ParentCommunity",description:"Community created for holding collection",mass_permissions:"public")
      @community.did = @community.pid
      @community.save!
      @did = @community.did}

    before(:each){

      # Creation of Collection object before each test which uses Community object above for as parent
      @collectionCreated = Collection.new(title:"New collection",description:"Collection to be embedded in Community",mass_permissions:"public")
      @collectionCreated.did = @collectionCreated.pid
      @collectionCreated.depositor = '000000000'
      @collectionCreated.save!
      @collectionCreated.community = @community
      @collectionCreated.save!
      @collectdid = @collectionCreated.did
    }

    after(:all) {

      Resque.inline = false
      User.destroy_all
    }

    let(:collection) {

      Collection.find_by_did params[:did]}


    # Testing Community creation
    # Purpose statement
    it 'community object should be created with id' do

      # Expecting the community created with same id as the one assigned during creation
      expect(@community.did). to eq @did
    end

    # Purpose statement
    it 'community object should created with assigned title' do

      # Expecting the community created with same title as the one passed during creation
      expect(@community.title). to eq "ParentCommunity"
    end

    # Purpose statement
    it 'community object should created with specified description' do

      # Expecting the community created with same description as the one passed during creation
      expect(@community.description). to eq "Community created for holding collection"
    end

    # Purpose statement
    it 'community object should created with specified mass permissions' do

      # Expecting the community created with same mass permission as the one passed during creation
      expect(@community.mass_permissions). to eq "public"
    end

    # Testing Collection creation
    # Purpose statement
    it 'collection object should created with assigned title' do

      # Expecting the collection created with same title as the one passed during creation
      expect(@collectionCreated.title). to eq "New collection"
    end

    # Purpose statement
    it 'collection object should created with assigned description' do

      # Expecting the collection created with same title as the one passed during creation
      expect(@collectionCreated.description). to eq "Collection to be embedded in Community"
    end

    # Purpose statement
    it 'collection object should created with assigned mass permission' do

      # Expecting the collection created with same mass permission as the one passed during creation
      expect(@collectionCreated.mass_permissions). to eq "public"
    end

    # Purpose statement
    it 'collection object should created with assigned depositor' do

      # Expecting the collection created with same depositor as the one passed during creation
      expect(@collectionCreated.depositor). to eq "000000000"
    end

    # Purpose statement
    it 'collection object should created with the community created above and not null ' do

      # Expecting the collection created with same title as the one passed during creation
      expect(@collectionCreated.community.id). to eq @did
    end

    # Creation of params object to pass it along with create function for Collection object creation
    let(:params) do
      {

          :collection => {
              :title => 'New collection',
              :description => 'This is a test collection.',
              :mass_permissions => 'public',
              :community => @community
          }
      }

    end

    # Purpose statement
    it 'should create a collection object and go to show page' do
      Collection.destroy_all
      sign_in @user
      # Calling the create function
      post :create, params

      # Retrieving the first object created in Collection class
      collection = Collection.first

      # Testing the object creation parameters
      #binding.pry

      # Expecting the post method to be successful and transfer the created collection resource to the show page
      expect(response.status).to eq 302

      expect(collection.title).to eq params[:collection][:title]
    end
  end


  # Testing the update function in the Collection Controller
  describe 'post #update' do
    Resque.inline = true
    let(:community) { FactoryBot.create :community }
    let(:collection) { FactoryBot.create :collection }
    let(:user) { FactoryBot.create(:user) }

    # Purpose statement
    it '302s for valid requests' do
      collection.did = collection.pid
      collection.community = community
      collection.depositor = user.id.to_s
      collection.save!
      params = { :did=> collection.did, :id=>collection.pid, :collection=>{:title=>'Updated collection', :mass_permissions=>'public', :community=>community, :description=>'Updated description'}}
      sign_in user
      # Calling the update function
      put :update, params

      # Expecting the post method to be successful and transfer the updated Collection resource to the show page
      expect(response.status).to eq 302
    end
    Resque.inline = false
  end

  after(:all){
    User.destroy_all
  }
end
