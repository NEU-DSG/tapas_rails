require 'spec_helper'

shared_examples_for "an API enabled controller" do    
  let(:user) { FactoryGirl.create(:user) } 

  describe "authentication" do 

    it "raises a 403 for requests with no attached user" do 
      post :upsert, { token: "blah" } 
      expect(response.status).to eq 403
    end

    it "raises a 403 for requests with no attached token" do 
      post :upsert, { email: "blah" }
      expect(response.status).to eq 403
    end

    it "raises a 403 for requests with an invalid token" do 
      post :upsert, { email: user.email, token: "blurgl" }
      expect(response.status).to eq 403
    end

    # Don't verify that the action does the right thing, since this request 
    # is probably still bupkes.  Just verify that it doesn't 403.
    it "doesn't 403 for requests with valid credentials" do
      pending "Ensure requests always generate at least a 500 error"
    end
  end
end
