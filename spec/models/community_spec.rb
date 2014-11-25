require 'spec_helper'

describe Community do 
  let(:community) { Community.new }

  after(:each) { Community.delete_all }

  it "can create the root community when it doesn't exist" do 
    expect{ Community.root_community }.to change{ Community.count }.from(0).to(1)
    expect(Community.root_community.pid).to eq Rails.configuration.tap_root
  end

  it "can look up the root community when it already exists" do 
    Community.root_community
    expect{ Community.root_community }.not_to change{ Community.count }.from(1)
    expect(Community.root_community.pid).to eq Rails.configuration.tap_root
  end
end
