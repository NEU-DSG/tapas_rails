require 'spec_helper'

describe CoreFilesController do
  include FileHelpers
  include FixtureBuilders
  include ValidAuthToken

  let(:core_file) { FactoryGirl.create :core_file }

  def test_file(fname)
    pth = Rails.root.join("spec", "fixtures", "files", fname)
    @file = Rack::Test::UploadedFile.new pth 
    return @file 
  end

  RSpec.shared_examples "a content displaying route" do 
    let(:route) { requested_content.to_sym }

    after(:each) { ActiveFedora::Base.delete_all }
    
    it '404s when no CoreFile can be found' do 
      get route, { :did => SecureRandom.uuid } 
  
      expect(response.status).to eq 404 
      expect(response.body).to include 'Resource not found'
    end

    it "404s when the CoreFile lacks the requested display type." do
      get route, { :did => core_file.did } 
      expect(response.status).to eq 404 
      expect(response.body).not_to be nil
    end

    it '200s and returns the content when it exists' do 
      html = FactoryGirl.create :html_file
      html.core_file = core_file 
      html.html_for << core_file 

      if requested_content == 'tei'
        html.canonize
      else
        html.html_type = requested_content
      end

      html_content = '<h1>Hello!</h1>' 
      html.content.content = html_content 
      html.save!

      get route, { :did => core_file.did } 

      expect(response.status).to eq 200 
      expect(response.body).to eq html_content
    end
  end

  describe 'GET teibp' do 
    it_behaves_like 'a content displaying route' do 
      let(:requested_content) { 'teibp' }
    end
  end

  describe 'GET tapas_generic' do 
    it_behaves_like 'a content displaying route' do 
      let(:requested_content) { 'tapas_generic' }
    end
  end

  describe 'GET tei' do 
    it_behaves_like 'a content displaying route' do 
      let(:requested_content) { 'tei' }
    end
  end

  describe 'GET mods' do 
    # Given that we are mostly trusting display_mods to output the right thing, 
    # this is a pretty light spec.
    it 'returns some content for nonempty metadata' do 
      core = FactoryGirl.create :core_file 
      did = core.did
      pid = core.pid
      core.mods.content = File.read(fixture_file('mods.xml'))
      core.did = did
      core.mods.identifier = pid
      core.save! 

      get :mods, { :did => core.did } 

      expect(response.body).to include 'Collection Ia, public'
    end
  end

  describe "DELETE destroy" do 
    after(:each) { ActiveFedora::Base.delete_all }

    it "404s for nonexistant dids" do 
      delete :destroy, { :did => "not a real did" }
      expect(response.status).to eq 404
    end

    it "404s for dids that don't belong to a CoreFile" do 
      community = Community.create(:did => "115", :depositor => "test")
      delete :destroy, { :did => community.did }
      expect(response.status).to eq 404
    end

    it "200s for dids that belong to a CoreFile and removes the resource" do 
      core = CoreFile.create(:did => "78382", :depositor => "test")
      delete :destroy, { :did => core.did }
      expect(response.status).to eq 200
      expect(CoreFile.find_by_did core.did).to be nil 
    end
  end

  describe 'GET #show' do 

    after(:all) { ActiveFedora::Base.delete_all } 

    it 'returns the success representation of the object for valid records' do 
      cf, col, proj = FixtureBuilders.create_all
      cf.mark_upload_complete!
      get :show, did: cf.did 

      expect(response.status).to eq 200 
      json = JSON.parse(response.body)
      expect(json['status']).to eq 'COMPLETE' 
    end

    it 'returns the in_progress representation of the object for processing records' do
      cf = FactoryGirl.create :core_file  
      cf.mark_upload_in_progress!

      get :show, did: cf.did 

      expect(response.status).to eq 200 
      json = JSON.parse(response.body) 
      expect(json['status']).to eq 'INPROGRESS'
    end

    it 'returns the failed representation of the object for failed records' do 
      cf = FactoryGirl.create :core_file
      cf.mark_upload_failed!

      get :show, did: cf.did 

      expect(response.status).to eq 200 
      json = JSON.parse(response.body)
      expect(json['status']).to eq 'FAILED'
    end

    it 'marks invalid tagless records as failed' do 
      cf = FactoryGirl.create :core_file # No associated collections, invalid

      get :show, did: cf.did 

      expect(response.status).to eq 200 
      json = JSON.parse(response.body)
      puts json
      expect(json['status']).to eq 'FAILED'
    end

    it 'flags records that are stuck in progress as failed' do 
      cf = FactoryGirl.create :core_file
      cf.mark_upload_in_progress
      cf.upload_status_time = 20.minutes.ago.utc.iso8601
      cf.save!

      get :show, did: cf.did 

      expect(response.status).to eq 200 
      json = JSON.parse(response.body)
      expect(json['status']).to eq 'FAILED'
      expect(json['errors_system'].first).to include 'more than five minutes'
    end
  end


  describe "POST #upsert" do
    let(:post_defaults) do 
      { :collection_dids => ["12345", "22345"],
        :did             => "111",
        :access          => "private",
        :depositor       => "wjackson",
        :tei             => test_file(fixture_file('tei.xml')),
        :support_files   => test_file(fixture_file('all_files.zip')),
        :file_types      => ['personography', 'bibliography'] }
    end

    after(:all) { ActiveFedora::Base.delete_all }

    it "returns a 202 and creates the desired file on a valid request." do 
      Resque.inline = true

      # Create a community for our collections to be attached to 
      community = FactoryGirl.create :community

      # Create the relevant collections
      collection_one = FactoryGirl.create :collection
      collection_one.did = post_defaults[:collection_dids][0]
      collection_one.community = community
      collection_one.save! 

      collection_two = FactoryGirl.create :collection
      collection_two.did = post_defaults[:collection_dids][1]
      collection_two.community = community
      collection_two.save!

      post :upsert, post_defaults

      expect(response.status).to eq 202

      core = CoreFile.find(CoreFile.find_by_did("111").id)
      tei  = core.canonical_object(:model)

      # Ensure support file content has been attached
      expect(core.thumbnail).to be_instance_of ImageThumbnailFile
      expect(core.page_images.count).to eq 3

      collection_pids = core.collections.map { |x| x.pid } 

      # Ensure collections have been attached
      expected_pids = [collection_one.pid, collection_two.pid]
      expect(collection_pids).to match_array expected_pids

      # Ensure TEI File content has been attached
      expect(tei.class).to eq TEIFile
      expect(tei.content.content.size).not_to eq 0 

      # Ensure file_types are set
      expect(collection_one.personographies).to eq [core]
      expect(collection_two.personographies).to eq [core] 
      expect(collection_one.bibliographies).to eq  [core]
      expect(collection_two.bibliographies).to eq  [core]

      Resque.inline = false
    end 
  end
  it_should_behave_like "an API enabled controller"
end
