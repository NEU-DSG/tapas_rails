require 'spec_helper'

describe CoreFilesController do
  include FileHelpers

  let (:user) { FactoryGirl.create(:user) }
  let(:params) { { email: user.email, token: "test_api_key" } } 

  def test_file(fname)
    pth = Rails.root.join("spec", "fixtures", "files", fname)
    @file = Rack::Test::UploadedFile.new pth 
    return @file 
  end

  describe "POST #upsert" do
    let(:post_defaults) do 
      { :collection_did => "12345",
        :did            => "111",
        :access         => "private",
        :depositor      => "wjackson",
        :files          => test_file(fixture_file("all_files.zip")),
        :file_type      => "tei_content", }
    end

    after(:all) { ActiveFedora::Base.delete_all }

    it "returns a 202 and creates the desired file on a valid request." do 
      Resque.inline = true
      post :upsert, params.merge(post_defaults)

      expect(response.status).to eq 202

      core = CoreFile.find(CoreFile.find_by_did("111").id)
      tei  = core.canonical_object(:model)
      tfc  = core.tfc.first

      expect(tei.class).to eq TEIFile
      expect(tei.content.content.size).not_to eq 0 

      expect(tfc.class).to eq TEIFile
      expect(tfc.content.content.size).not_to eq 0


      Resque.inline = false
    end 
  end
  it_should_behave_like "an API enabled controller"
end
