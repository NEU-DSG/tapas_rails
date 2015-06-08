require "spec_helper" 

describe UpsertCoreFile do 
  include FileHelpers

  describe "#update_metadata!" do
    before(:all) do 
      @params = { 
        :depositor => "tapas@neu.edu",
        :access => "public",
        :collection_did => "111",
        :file_type => "otherography",
      }

      upserter = UpsertCoreFile.new @params
      upserter.file_hash = {}
      upserter.file_hash[:mods] = fixture_file "mods.xml" 
      upserter.core_file = @core = CoreFile.new
      upserter.update_metadata!
      @core.reload
    end

    after(:all) { @core.delete } 

    it "sets the depositor equal to params[:depositor]" do 
      expect(@core.depositor).to eq @params[:depositor]
    end

    it "sets the drupal access level equal to params[:access]" do 
      expect(@core.drupal_access).to eq @params[:access] 
    end

    it "assigns the object to the phantom collection when no collection" \
      "with params[:collection_did] exists" do 
      pid = Rails.configuration.phantom_collection_pid
      expect(@core.collection.pid).to eq pid
    end

    # This test relies on usage of the mods.xml file
    it "assigns the metadata from the mods_path field to the mods record" do 
      expect(@core.mods.title.first).to eq "Test X, private"
    end
    
    it "writes the object's did to the MODS record" do 
      expect(@core.did).to eq @params[:did] 
    end

    it "writes the object's file type" do 
      expect(@core.otherography_for.first).to eq Collection.phantom_collection
    end
  end
end
