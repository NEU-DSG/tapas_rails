require 'spec_helper'
require 'pry-debugger'

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
  #     core_file = FactoryGirl.create :core_file
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

  # describe 'POST #upsert' do
  #   before(:all) { Resque.inline = true }
  #   after(:each) { ActiveFedora::Base.delete_all }
  #   after(:all) { Resque.inline = false }
  #   let(:community) { Community.find_by_did params[:did] }
  #
  #   let(:params) do
  #     { :title => 'Test Community',
  #       :depositor => '000000000',
  #       :description => 'This is a test community.',
  #       :members => %w(1 2 3),
  #       :access => 'public',
  #       :did => '12',
  #       :thumbnail => Rack::Test::UploadedFile.new(fixture_file('image.jpg')),
  #     }
  #   end
  #
  #   it '422s for invalid requests' do
  #     post :upsert, params.except(:depositor)
  #     expect(response.status).to eq 422
  #   end
  #
  #   it 'returns a 202 and creates community on requests with new dids.' do
  #     #binding.pry
  #     post :upsert, params
  #
  #     expect(response.status).to eq 202
  #     expect(community.depositor).to eq params[:depositor]
  #   end
  #
  #   it 'returns a 202 and updates the requested community if it exists' do
  #     community_old = Community.new
  #     #.mods removed
  #     community_old.title = 'Test Community'
  #     community_old.description = 'This is a test'
  #     community_old.did = params[:did]
  #     community_old.depositor = 'System'
  #     community_old.project_members = ['303']
  #     community_old.save!
  #
  #     post :upsert, params
  #     expect(response.status).to eq 202
  #     expect(community.depositor).to eq 'System'
  #     expect(community.project_members).to eq ['1', '2', '3']
  #   end
  # end

  #Newly added test for update function
  describe 'post #update' do
    before(:all) { Resque.inline = true }
    after(:each) { ActiveFedora::Base.delete_all }
    after(:all) { Resque.inline = false }
    let(:community) { Community.find_by_did params[:did] }

    let(:params) do
      {
        :did => '12',
        :community => {
            :title => 'New Community',
            #:depositor => ['000000000'],
            :description => 'This is a test community.',
            #:members => %w(1 2 3),
            :mass_permissions => 'public'
            #:thumbnail => Rack::Test::UploadedFile.new(fixture_file('image.jpg'))
        }
      }
    end

    it '302s for valid requests' do
      community_old = Community.new
      #.mods removed
      community_old.title = 'Test Community'
      community_old.description = 'This is a test'
      community_old.mass_permissions = 'private'
      community_old.did = params[:did]
      community_old.depositor = 'System'
      community_old.project_members = ['303']
      community_old.save!
      params[:id] = community_old.did
      #binding.pry
      put :update, params
      expect(response.status).to eq 302
    end
  end

  describe 'get #new' do
    #before(:all) { Resque.inline = true }
    #after(:each) { ActiveFedora::Base.delete_all }
    #after(:all) { Resque.inline = false }
    #let(:community) { Community.find_by_did params[:did] }

    it 'should create a community object' do
      #community = Community.new
      get :new
      #binding.pry
      expect(assigns(:community)).to be_a_new(Community)
      #expect(community.class).to eq 302
    end
  end

  describe 'post #create' do
    before(:all) { Resque.inline = true }
    after(:each) { ActiveFedora::Base.delete_all }
    after(:all) { Resque.inline = false }
    let(:community) { Community.find_by_did params[:did] }

    let(:params) do
      {
          :community => {
              :title => 'New Community',
              #:depositor => ['000000000'],
              :description => 'This is a test community.',
              #:members => %w(1 2 3),
              :mass_permissions => 'public'
              #:thumbnail => Rack::Test::UploadedFile.new(fixture_file('image.jpg'))
          }
      }
    end

    it '422s for invalid requests' do
      #community_old = Community.new
      #.mods removed
       # community_old.title = 'Test Community'
       # community_old.description = 'This is a test'
       # community_old.mass_permissions = 'private'
       # community_old.did = params[:did]
      #community_old.save!
      #params[:id] = community_old.id
      #binding.pry
      post :create, params
      community = Community.first

      #binding.pry
      expect(response.status).to eq 302
      expect(community.title).to eq params[:community][:title]
    end
  end

  # describe 'get #edit' do
  #   before(:all) { Resque.inline = true }
  #   after(:each) { ActiveFedora::Base.delete_all }
  #   after(:all) { Resque.inline = false }
  #   let(:community) { Community.find_by_did params[:did] }
  #
  #   let(:params) do
  #     {
  #         :title => '',
  #         :depositor => '000000000',
  #         :description => 'This is a test community.',
  #         :members => %w(1 2 3),
  #         :access => 'public',
  #         :did => '12',
  #         :thumbnail => Rack::Test::UploadedFile.new(fixture_file('image.jpg')),
  #     }
  #   end
  #
  #   it '422s for invalid requests' do
  #     community_old = Community.new
  #     #.mods removed
  #     community_old.title = 'Test Community'
  #     community_old.description = 'This is a test'
  #     community_old.did = params[:did]
  #     community_old.depositor = 'System'
  #     community_old.project_members = ['303']
  #     community_old.save!
  #     get :edit, params
  #     expect(response.status).to eq 422
  #   end
  # end

    it_should_behave_like 'an API enabled controller'
end
