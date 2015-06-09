require 'spec_helper'

shared_examples_for "an API enabled controller" do    
  let(:user) { FactoryGirl.create(:user) } 

  describe "authentication" do 

    it "raises a 403 for requests with no authorization header" do
      request.env['HTTP_AUTHORIZATION'] = nil
      post :upsert
      expect(response.status).to eq 403
    end

    it "raises a 403 for requests with an invalid token" do 
      request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::
        Token.encode_credentials(SecureRandom.hex)
      post :upsert
      expect(response.status).to eq 403
    end
  end
end
