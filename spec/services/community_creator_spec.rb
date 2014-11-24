require 'spec_helper'

describe CommunityCreator do 
  describe "A clean run" do 
    before(:all) do 
      @root = Community.new(pid: Rails.configuration.tap_root)
      @root.save!
      
      params = {}
      params[:nid] = "111"
      params[:title] = "Sample Project"
      params[:members] = %w(1 2 3 4)
      params[:description] = "A sample project." 
      @community = CommunityCreator.create_record(params)
    end
    
    after(:all) { @root.destroy ; @community.destroy } 

    it "saves the object" do 
      expect{ Community.find(@community.pid) }.not_to raise_error 
    end

    it "assigns the nid to the object" do 
      expect(@community.nid).to eq "111"
    end

    it "assigns the title to the object" do 
      expect(@community.mods.title.first).to eq "Sample Project"
    end

    it "assigns the users to the members field" do 
      expect(@community.project_members).to match_array %w(1 2 3 4)
    end

    it "assigns the community to the root community" do 
      expect(@community.community.pid).to eq Rails.configuration.tap_root
    end
  end
  
  describe "A run that errors out", :type => :mailer do 
    after(:all) { ActiveFedora::Base.delete_all }

    it "doesn't persist the community and triggers an exception notification" do 
      params = {
        :title => "My Collection",
        :nid   => "123",
        :description => "A collection",
        :members     => %w(1 2),
      }

      Community.any_instance.stub(:community_id=).and_raise(RuntimeError)

      expect { CommunityCreator.create_record(params) }.to raise_error(RuntimeError)

      expect(Community.count).to eq 0
      expect(ActionMailer::Base.deliveries.length).to eq 1
    end
  end
end

