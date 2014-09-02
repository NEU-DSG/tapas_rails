require 'spec_helper'

shared_examples_for "a JSON accessible API" do 
  before(:all) do 
    Rails.configuration.action_controller.allow_forgery_protection = true
  end

  pending "Figure out how to test CSRF enable/disable"

  it "rejects requests with no token" do 

  end

  it "rejects requests with an invalid token" do 

  end

  it "allows requests with a valid token" do 

  end

  after(:all) do 
    Rails.configuration.action_controller.allow_forgery_protection = false 
  end
end