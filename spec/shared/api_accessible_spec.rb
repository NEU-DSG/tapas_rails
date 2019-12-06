require 'spec_helper'

shared_examples_for "an API enabled controller" do    
  let(:user) { FactoryGirl.create(:user) } 

  describe "authentication" do 
    it "raises a 403 for requests with no authorization header" do
      set_auth_token(nil)
      post :upsert, :did => 'whatever'
      expect(response.status).to eq 403
    end

    it "raises a 403 for requests with an invalid token" do 
      set_auth_token('bupkes')
      post :upsert, :did => 'whatever'
      expect(response.status).to eq 403
    end
  end
end
