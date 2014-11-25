require 'spec_helper'

describe CoreFilesController do
  let (:user) { FactoryGirl.create(:user) }
  let(:params) { { email: user.email, token: "test_api_key" } } 

  def test_file(fname)
    pth = Rails.root.join("spec", "fixtures", "files", fname)
    @file = Rack::Test::UploadedFile.new pth 
    return @file 
  end

  describe "POST #parse_tei" do 
    let(:body)   { JSON.parse response.body } 

    it "raises a fatal error and 422s with invalid XML" do 
      post :parse_tei, params.merge({ file: test_file("image.jpg") })
      expect(response.status).to eq 422 
    end

    it "raises a fatal error and 422s with XML that isn't TEI" do 
      post :parse_tei, params.merge({file: test_file("xml.xml") })
      expect(response.status).to eq 422
    end
    
    it "responds with a 200 for files that are valid TEI" do 
      post :parse_tei, params.merge({file: test_file("tei.xml")})
      expect(response.status).to eq 200 
    end
  end

  describe "POST #create" do
    before(:each) do 
      @src = "#{Rails.root}/spec/fixtures/files/tei.xml"
    end

    let(:post_defaults) do 
      { :collection => "12345",
        :nid        => "111",
        :depositor  => "wjackson",
        :file       => test_file(@src) }
    end

    after(:all) { ActiveFedora::Base.delete_all }

    # Note that we force Resque to run inline for the duration of this spec.
    it "returns a 202 and creates the desired file on a valid request." do 
      Resque.inline = true
      file_path = post_defaults[:file].path
      post :create, params.merge(post_defaults)

      expect(response.status).to eq 202

      core = CoreFile.find(CoreFile.find_by_nid("111").id)
      tei  = core.canonical_object(:return_as => :models)

      expect(tei.class).to eq TEIFile
      expect(tei.content.content).to eq File.read(@src)
      expect(File.exists? file_path).to be false

      Resque.inline = false
    end 
  end
  it_should_behave_like "an API enabled controller"
end
