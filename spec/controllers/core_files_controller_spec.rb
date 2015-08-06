require 'spec_helper'

describe CoreFilesController do
  include FileHelpers
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
      expected_msg = 'No record associated with this did was found.' 
      expect(response.body).to eq expected_msg
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

  describe "DELETE destroy" do 
    after(:each) { ActiveFedora::Base.delete_all }

    it "422s for nonexistant dids" do 
      delete :destroy, { :did => "not a real did" }
      expect(response.status).to eq 422
    end

    it "422s for dids that don't belong to a CoreFile" do 
      community = Community.create(:did => "115", :depositor => "test")
      delete :destroy, { :did => community.did }
      expect(response.status).to eq 422
    end

    it "200s for dids that belong to a CoreFile and removes the resource" do 
      core = CoreFile.create(:did => "78382", :depositor => "test")
      delete :destroy, { :did => core.did }
      expect(response.status).to eq 200
      expect(CoreFile.find_by_did core.did).to be nil 
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
        :file_type       => "tei_content", }
    end

    after(:all) { ActiveFedora::Base.delete_all }

    it "returns a 202 and creates the desired file on a valid request." do 
      Resque.inline = true

      # Create the relevant collections
      collection_one = FactoryGirl.create :collection
      collection_one.did = post_defaults[:collection_dids][0]
      collection_one.save! 

      collection_two = FactoryGirl.create :collection
      collection_two.did = post_defaults[:collection_dids][1]
      collection_two.save!

      post :upsert, post_defaults

      expect(response.status).to eq 202

      core = CoreFile.find(CoreFile.find_by_did("111").id)
      tei  = core.canonical_object(:model)

      expect(core.thumbnail).to be_instance_of ImageThumbnailFile
      expect(core.page_images.count).to eq 3

      collection_pids = core.collections.map { |x| x.pid } 

      expected_pids = [collection_one.pid, collection_two.pid]
      expect(collection_pids).to match_array expected_pids

      expect(tei.class).to eq TEIFile
      expect(tei.content.content.size).not_to eq 0 

      Resque.inline = false
    end 
  end
  it_should_behave_like "an API enabled controller"
end
