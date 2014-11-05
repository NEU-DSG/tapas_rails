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
    it "returns a 422 for uploads that lack a depositor field" do 
      data = { file: test_file("tei.xml"), collection: "1" }
      post :create, params.merge(data)

      expect(response.status).to eq 422 
    end

    it "returns a 422 for uploads that lack a collection id field" do
      data = { file: test_file("tei.xml"), depositor: "w@w.net" } 
      post :create, params.merge(data) 

      expect(response.status). to eq 422 
    end

    it "returns a 202 processing for valid uploads" do 
      data = { file: test_file("tei.xml"),
               depositor: "123@abc.com", 
               collection: "1" }
      post :create, params.merge(data)

      expect(response.status).to eq 202
    end 
  end

  it_should_behave_like "an API enabled controller"
end
