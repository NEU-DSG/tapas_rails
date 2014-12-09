require 'spec_helper'

describe CommunityCreator do 
  describe "A clean run" do 
    before(:all) do 
      @root = Community.new(pid: Rails.configuration.tap_root)
      @root.save!
      
      @params = {
        :nid => "111",
        :title => "Sample Project",
        :access => "public",
        :members => %w(1 2 3 4),
        :depositor => "101"
      }
      @community = CommunityCreator.create_record(@params)
    end
    
    after(:all) { @root.destroy ; @community.destroy } 

    it "saves the object" do 
      expect{ Community.find(@community.pid) }.not_to raise_error 
    end

    it "assigns the depositor to the object" do 
      expect(@community.depositor).to eq @params[:depositor]
    end

    it "assigns the drupal access level to the object" do 
      expect(@community.drupal_access).to eq @params[:access]
    end

    it "assigns the nid to the object" do 
      expect(@community.nid).to eq @params[:nid]
    end

    it "assigns the title to the object" do 
      expect(@community.mods.title.first).to eq @params[:title]
    end

    it "assigns the users to the members field" do 
      expect(@community.project_members).to match_array @params[:members]
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
        :access => "public",
        :depositor => "101",
        :members     => %w(1 2),
      }

      Community.any_instance.stub(:community=).and_raise(RuntimeError)

      expect { CommunityCreator.create_record(params) }.to raise_error(RuntimeError)

      expect(Community.find_by_nid params[:nid]).to be nil
      expect(ActionMailer::Base.deliveries.length).to eq 1
    end
  end
end

