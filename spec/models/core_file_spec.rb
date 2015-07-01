require "spec_helper" 

describe CoreFile do 
  describe "Collections relationship" do 
    let(:core_file) { FactoryGirl.create :core_file }

    it { respond_to :collections }
    it { respond_to :collections= }
    it { should_not respond_to :collection } 
    it { should_not respond_to :collection= }

    after(:each) { ActiveFedora::Base.delete_all }

    it "are manipulated as arrays" do 
      c, d = FactoryGirl.create_list(:collection, 2)

      core_file.collections << c 
      core_file.collections << d 

      expect(core_file.collections).to match_array [c, d]
    end
  end

  describe "#project" do 

    after(:each) { ActiveFedora::Base.delete_all } 

    it "returns nil for CoreFiles that belong to no collections" do 
      core_file = FactoryGirl.create :core_file 

      expect(core_file.project).to be nil
    end

    it "returns nil for CoreFiles that belong to orphaned collections" do 
      core_file = FactoryGirl.create :core_file
      collection = FactoryGirl.create :collection

      core_file.collections << collection
      core_file.save! 

      expect(core_file.project).to be nil
    end

    it "returns a project for CoreFiles that belong to an OK collection" do 
      core_file = FactoryGirl.create :core_file 
      collection = FactoryGirl.create :collection 
      community = FactoryGirl.create :community 

      core_file.collections << collection 
      core_file.save! 

      collection.community = community 
      collection.save! 

      expect(core_file.project.pid).to eq community.pid
    end

  end

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
        community = Community.create(:depositor => "Will", :did => "1176")
        other_community = Community.create(:depositor => "Will", :did => "1177")

        core.otherography_for << community
        core.otherography_for << other_community 

        expect(core.otherography_for).to match_array [community, other_community]

        core.otherography_for = [community]

        expect(core.otherography_for).to match_array [community]
      ensure
        core.delete if core.persisted?
        community.delete if community.persisted?
        other_community.delete if other_community.persisted?
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
