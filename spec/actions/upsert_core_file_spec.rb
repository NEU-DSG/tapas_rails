require "spec_helper" 

describe UpsertCoreFile do 
  include FileHelpers

  describe "#update_metadata!" do
    before(:all) do 
      ActiveFedora::Base.delete_all

      @params = { 
        :depositor => "tapas@neu.edu",
        :access => "public",
        :collection_dids => ["111"],
        :file_type => "otherography",
      }

      @collection = FactoryGirl.create(:collection)
      @collection.did = @params[:collection_dids].first
      @collection.save!

      # Ography assignment depends on a given TEI File 
      # being able to determine which project it belongs to, 
      # hence bothering to create a community here.
      @community = FactoryGirl.create(:community)
      @collection.community = @community
      @collection.save!

      upserter = UpsertCoreFile.new @params
      upserter.core_file = @core = CoreFile.new
      upserter.update_metadata!
      @core.reload
    end

    after(:all) { ActiveFedora::Base.delete_all } 

    it "sets the depositor equal to params[:depositor]" do 
      expect(@core.depositor).to eq @params[:depositor]
    end

    it "sets the drupal access level equal to params[:access]" do 
      expect(@core.drupal_access).to eq @params[:access] 
    end

    it "assigns the object to all collections listed in collection_dids" do 
      expect(@core.collections).to match_array [@collection]
    end

    it "sets og reference to the provided collection_dids" do 
      expect(@core.og_reference).to match_array @params[:collection_dids]
    end
    
    it "writes the object's did to the MODS record" do 
      expect(@core.did).to eq @params[:did] 
    end

    it "writes the object's file type" do 
      expect(@core.otherography_for.first.pid).to eq @community.pid
    end
  end
end
