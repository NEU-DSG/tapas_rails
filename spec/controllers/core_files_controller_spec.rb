require 'spec_helper'

describe CoreFilesController do
  let (:user) { FactoryGirl.create(:user) }

  describe "POST#parse_tei" do 
    def test_file(fname)
      pth = Rails.root.join("spec", "fixtures", "files", fname)
      @file = Rack::Test::UploadedFile.new pth 
      return @file 
    end

    let(:params) { { email: user.email, token: "test_api_key" } } 
    let(:body)   { JSON.parse response.body } 

    it "raises a fatal error and 422s with invalid XML" do 
      post :parse_tei, params.merge({ file: test_file("image.jpg") })
      expect(response.status).to eq 422 
    end

    it "raises a fatal error and 422s with XML that isn't TEI" do 
      post :parse_tei, params.merge({file: test_file("xml.xml") })
      expect(response.status).to eq 422
    end
    
    pending "test metadata extraction"
  end

  it_should_behave_like "an API enabled controller"
end
