require 'spec_helper'

shared_examples_for "a JSON accessible API" do 
  let(:user) { FactoryGirl.create(:user) } 

  it "403s for requests with no attached user" do 
    post :create, { token: "blah", format: "json" } 
    expect(response.status).to eq 403
  end

  it "403s for requests with no attached token" do 
    post :create, { email: "blah", format: "json" } 
    expect(response.status).to eq 403
  end

  it "rejects requests with an invalid token" do 
    post :create, { email: user.email, token: "blurgl", format: "json" }
    expect(response.status).to eq 403
  end

  # Don't verify that the action does the right thing, since this request 
  # is probably still bupkes.  Just verify that it doesn't 403.
  it "allows requests with a valid token" do 
    post :create, { email: user.email, token: "test_api_key", format: "json" }
    expect(response.status).not_to eq 403
  end
end