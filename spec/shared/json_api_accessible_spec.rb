require 'spec_helper'

shared_examples_for "a JSON accessible API" do 
  let(:user) { FactoryGirl.create(:user) } 
  before(:all) do 
    Rails.configuration.action_controller.allow_forgery_protection = true
  end

  pending "Figure out how to test CSRF enable/disable"

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

  it "allows requests with a valid token" do 
    post :create, { email: user.email, token: "test_api_key", format: "json" }
    expect(response.status).not_to eq 403
  end

  after(:all) do 
    Rails.configuration.action_controller.allow_forgery_protection = false 
  end
end