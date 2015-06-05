require "spec_helper" 

describe CoreFile do 
  describe "TFC relationship" do 
    it { respond_to :tfc } 
    it { respond_to :tfc= } 
    
    after(:each) { ActiveFedora::Base.delete_all }

    it "can be set on the CoreFile but is written to the TEIFile" do 
      core = CoreFile.create(:depositor => "will", :did => SecureRandom.hex) 
      tei  = TEIFile.create(:depositor => "Will") 

      core.tfc << tei ; core.save! 

      expect(tei.tfc_for).to match_array [core]
    end
  end

  describe "Ography relationships" do 
    it { respond_to :personography_for }
    it { respond_to :personography_for= }
    it { respond_to :orgography_for }
    it { respond_to :bibliography_for }
    it { respond_to :bibliography_for= }
    it { respond_to :otherography_for }
    it { respond_to :otherography_for= }
    it { respond_to :odd_file_for }
    it { respond_to :odd_file_for= }

    it "are manipulated as arrays" do 
      begin
        core = CoreFile.create(:depositor => "Will", :did => "1175")
        collection = Collection.create(:depositor => "Will", :did => "1176")
        other_collection = Collection.create(:depositor => "Will", :did => "1177")

        core.otherography_for << collection
        core.otherography_for << other_collection 

        expect(core.otherography_for).to match_array [collection, other_collection]

        core.otherography_for = [collection]

        expect(core.otherography_for).to match_array [collection]
      ensure
        core.delete if core.persisted?
        collection.delete if collection.persisted?
        other_collection.delete if other_collection.persisted?
      end
    end
  end

  describe "Page Image relationships" do 
    it { respond_to :page_images }
    it { respond_to :page_images= }

    it "can be set on the Core File object but are written to the IMF" do 
      begin
        core_file = CoreFile.create(:did => "123", :depositor => "Will")
        imf = ImageMasterFile.create(:depositor => "Will")

        expect(core_file.page_images).to eq []

        core_file.page_images << imf 
        core_file.save!

        expect(imf.page_image_for.first.pid).to eq core_file.pid
      ensure
        core_file.delete if core_file.persisted?
        imf.delete if imf.persisted?
      end
    end
  end

  describe "HTML Object Queries" do 
    let(:core_file) { FactoryGirl.create(:core_file) } 
    before(:each) { setup_html_tests }
    after(:each) { core_file.destroy } 

    def setup_html_tests
      @teibp = HTMLFile.create(:depositor => core_file.depositor)
      @teibp.html_for << core_file 
      @teibp.core_file = core_file
      @teibp.html_type = "teibp"
      @teibp.save!

      @tapas_generic = HTMLFile.create(:depositor => core_file.depositor) 
      @tapas_generic.html_for << core_file 
      @tapas_generic.core_file = core_file
      @tapas_generic.html_type = "tapas_generic" 
      @tapas_generic.save!
    end

    it "can retrieve this CoreFile's teibp object" do 
      expect(core_file.teibp.class).to eq HTMLFile
      expect(core_file.teibp.pid).to eq @teibp.pid 

      expect(core_file.teibp(:raw)['id']).to eq @teibp.pid 
      expect(core_file.teibp(:solr_doc).pid).to eq @teibp.pid
    end

    it "can retrieve this CoreFile's tapas_generic object" do 
      expect(core_file.tapas_generic.class).to eq HTMLFile 
      expect(core_file.tapas_generic.pid).to eq @tapas_generic.pid

      expect(core_file.tapas_generic(:raw)['id']).to eq @tapas_generic.pid
      expect(core_file.tapas_generic(:solr_doc).pid).to eq @tapas_generic.pid 
    end
  end
end
