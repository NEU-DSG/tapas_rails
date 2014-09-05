require 'spec_helper'

shared_examples_for "an API enabled controller" do    
  let(:user) { FactoryGirl.create(:user) } 

  it "which 403s for requests with no attached user" do 
    post :create, { token: "blah" } 
    expect(response.status).to eq 403
  end

  it "which 403s for requests with no attached token" do 
    post :create, { email: "blah" }
    expect(response.status).to eq 403
  end

  it "which rejects requests with an invalid token" do 
    post :create, { email: user.email, token: "blurgl" }
    expect(response.status).to eq 403
  end

  # Don't verify that the action does the right thing, since this request 
  # is probably still bupkes.  Just verify that it doesn't 403.
  it "which allows requests with a valid token" do 
    post :create, { email: user.email, token: "test_api_key" }
    expect(response.status).not_to eq 403
  end
end