require 'spec_helper'

describe Community do 
  after(:each) { ActiveFedora::Base.delete_all }

  it "can create the root community when it doesn't exist" do 
    expect{ Community.root_community }.to change{ Community.count }.from(0).to(1)
    expect(Community.root_community.pid).to eq Rails.configuration.tap_root
  end

  it "can look up the root community when it already exists" do 
    Community.root_community
    expect{ Community.root_community }.not_to change{ Community.count }.from(1)
    expect(Community.root_community.pid).to eq Rails.configuration.tap_root
  end

  describe "Ography relationships" do 
    it { respond_to :personographies } 
    it { respond_to :orgographies } 
    it { respond_to :bibliographies }
    it { respond_to :otherographies } 
    it { respond_to :odd_files }
    it { respond_to :personographies= }
    it { respond_to :orgographies= }
    it { respond_to :bibliographies= }
    it { respond_to :otherographies= }
    it { respond_to :odd_files= }

    it "can be set on core files from the community" do 
      community = FactoryGirl.create :community
      core_file = FactoryGirl.create :core_file

      community.orgographies << core_file
      community.save!

      expect(core_file.orgography_for.first.pid).to eq community.pid
      expect(community.reload.orgographies).to match_array [core_file]
    end
  end
end
