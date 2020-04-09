require 'spec_helper'

describe CommunitiesController do
  include ValidAuthToken
  include FileHelpers

  # describe 'DELETE #destroy' do
  #   after(:each) { ActiveFedora::Base.delete_all }
  #
  #   it '404s for dids that do not exist' do
  #     delete :destroy, { :did => 'doesnt_exist' }
  #     expect(response.status).to eq 404
  #   end
  #
  #   it '404s for dids that do not belong to a Community' do
  #     core_file = FactoryBot.create :core_file
  #     delete :destroy, { :did => core_file.did }
  #     expect(response.status).to eq 404
  #     expect { core_file.reload }.not_to raise_error
  #   end
  #
  #   it '200s for successful requests and deletes all descendent objects' do
  #     community = Community.create(:did => '123575', :depositor => 'test')
  #     collection = Collection.create(:did => '128654', :depositor => 'test')
  #     collection.save! ; collection.community = community ; collection.save!
  #     delete :destroy, { :did => community.did }
  #     expect(response.status).to eq 200
  #     expect(Community.find_by_did community.did).to be nil
  #     expect(Collection.find_by_did collection.did).to be nil
  #   end
  # end

    describe 'POST #upsert' do
      before(:all) { Resque.inline = true }
      after(:each) { ActiveFedora::Base.delete_all }
      after(:all) { Resque.inline = false }
      let(:community) { Community.find_by_did params[:did] }

      let(:params) do
        { :title => 'Test Community',
          :depositor => '000000000',
          :description => 'This is a test community.',
          :members => %w(1 2 3),
          :access => 'public',
          :did => '12',
          :thumbnail => Rack::Test::UploadedFile.new(fixture_file('image.jpg')),
        }
      end

      it '422s for invalid requests' do
        post :upsert, params.except(:depositor)
        expect(response.status).to eq 422
      end

      it 'returns a 202 and creates community on requests with new dids.' do
        post :upsert, params

        expect(response.status).to eq 202
        expect(community.depositor).to eq params[:depositor]
      end

      it 'returns a 202 and updates the requested community if it exists' do
        community_old = Community.new
        community_old.title = 'Test Community'
        community_old.did = params[:did]
        community_old.depositor = 'System'
        community_old.project_members = ['303']
        community_old.save!

        post :upsert, params
        expect(response.status).to eq 202
        expect(community.depositor).to eq 'System'
        expect(community.project_members).to eq ['1', '2', '3']
      end
    end

    it_should_behave_like 'an API enabled controller'

  # Testing the new function defined in Community Controller
  describe 'get #new' do

    # Purpose statement
    it 'should create a community object' do

      # Calling create function
      get :new

      # Testing the object creation parameters
      #binding.pry

      # Checking whether the new object is of class type Community
      expect(assigns(:community)).to be_a_new(Community)
    end
  end

  # Testing the create function in the Community Controller
  describe 'post #create' do

    # Creation of community object used later for confirmation of working of create functionality
    before(:all) {

      Resque.inline = true
      @user = FactoryBot.create(:user)
      @communityCreated = Community.new(title:'New Community',depositor:@user.id.to_s,description:'This is a test community.',mass_permissions:'public')
      @communityCreated.did = @communityCreated.pid
      @communityCreated.save!
      @did = @communityCreated.did
    }
    after(:each) {

      ActiveFedora::Base.delete_all }

    after(:all) {

      Resque.inline = false
      @user.destroy
     }

    let(:community) {

      Community.find_by_did params[:did] }

    # Creation of params object to pass it along with create function for Community object creation
    let(:params) do
      {
          :community => {
              :title => 'New Community',
              :description => 'This is a test community.',
              :mass_permissions => 'public',
              :depositor => @user.id.to_s
          }
      }

    end

    # Purpose statement
    it 'should create a community object and go to show page' do

      # Calling the create function
      sign_in @user
      post :create, params

      # Retrieving the first object created in Community class
      community = Community.first

      # Testing the object creation parameters
      #binding.pry

      # Expecting the post method to be successful and transfer the created community resource to the show page
      expect(response.status).to eq 302

      expect(community.title).to eq params[:community][:title]

    end

    # Purpose statement
    it 'community title should be consistent' do

      # Expecting the community created with same parameters as params to have identical title
      expect(@communityCreated.title).to eq params[:community][:title]
    end

    # Purpose statement
    it 'community depositor should be consistent' do

      # Expecting the community created with same parameters as params to have identical depositor value
      expect(@communityCreated.depositor).to eq @user.id.to_s
    end

    # Purpose statement
    it 'community description should be consistent' do

      # Expecting the community created with same parameters as params to have identical description
      expect(@communityCreated.description).to eq params[:community][:description]
    end

    # Purpose statement
    it 'community mass permission should be consistent' do

      # Expecting the community created with same parameters as params to have identical mass permissions
      expect(@communityCreated.mass_permissions).to eq params[:community][:mass_permissions]
    end
  end


  describe 'post #update' do
    Resque.inline = true
    let(:community) { FactoryBot.create :community }
    let(:user) { FactoryBot.create(:user) }

    # Purpose statement
    it '302s for valid requests' do
      sign_in user
      community.did = community.pid
      community.depositor = user.id.to_s
      community.save!
      params = { :did=> community.did, :id=>community.pid, :community=>{:title=>'Updated community', :mass_permissions=>'public', :description=>'Updated description'}}

      # Calling the update function
      put :update, params

      # Expecting the post method to be successful and transfer the updated community resource to the show page
      expect(response.status).to eq 302
    end
    Resque.inline = false
  end

  after(:all){
    ActiveFedora::Base.delete_all
    User.destroy_all
  }
end
