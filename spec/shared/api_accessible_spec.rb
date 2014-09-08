require 'spec_helper'

shared_examples_for "an API enabled controller" do    
  let(:user) { FactoryGirl.create(:user) } 

  describe "authentication" do 

    it "raises a 403 for requests with no attached user" do 
      post :create, { token: "blah" } 
      expect(response.status).to eq 403
    end

    it "raises a 403 for requests with no attached token" do 
      post :create, { email: "blah" }
      expect(response.status).to eq 403
    end

    it "raises a 403 for requests with an invalid token" do 
      post :create, { email: user.email, token: "blurgl" }
      expect(response.status).to eq 403
    end

    # Don't verify that the action does the right thing, since this request 
    # is probably still bupkes.  Just verify that it doesn't 403.
    it "doesn't 403 for requests with valid credentials" do
      post :create, { email: user.email, token: "test_api_key" }
      expect(response.status).not_to eq 403
    end
  end

  describe "content validation" do 

    it "returns a 422 for invalid requests" do 
      post :create, {email: user.email, token: "test_api_key" } 
      expect(response.status).to eq 422
      msg = "Resource creation failed.  Invalid parameters!" 

      # Parse the response string into actual JSON
      body = JSON.parse response.body 
      # Ensure we're getting the error we expect
      expect(body["message"]).to eq msg
    end
  end
end