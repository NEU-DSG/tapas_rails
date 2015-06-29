require 'spec_helper'

describe CoreFilesController do
  include FileHelpers
  include ValidAuthToken

  def test_file(fname)
    pth = Rails.root.join("spec", "fixtures", "files", fname)
    @file = Rack::Test::UploadedFile.new pth 
    return @file 
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
