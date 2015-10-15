require "spec_helper" 

describe CoreFile do 
  include FileHelpers
  include FixtureBuilders

  let(:core_file) { FactoryGirl.create :core_file }
  let(:collection) { FactoryGirl.create :collection } 
  let(:community) { FactoryGirl.create :community }

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

  describe '#as_json' do 
    before(:each) { ActiveFedora::Base.delete_all }

    it 'returns a valueless hash for empty CoreFiles' do 
      result = CoreFile.new.as_json
      keys = %i(collection_dids tei support_files depositor access)

      expect(keys.all? { |k| result.has_key?(k) }).to be true 
      expect(result.all? { |k, v| v.blank?}).to be true
    end

    it 'returns a populated hash when given values' do 
      core_file, collections, project = FixtureBuilders.create_all

      # Add TEI to the file 
      Content::UpsertTei.execute(core_file, fixture_file('tei.xml'))

      # Add page images to the file
      images = [fixture_file('image.jpg'), fixture_file('other_image.jpg')]
      Content::UpsertPageImages.execute(core_file, images)

      core_file.reload

      core_file.depositor = 'William'

      result = core_file.as_json

      expect(result[:depositor]).to eq 'William'
      expect(result[:tei]).to eq 'tei.xml'
      expect(result[:support_files]).to eq %w(image.jpg other_image.jpg)
      expect(result[:access]).to eq 'private'
      expect(result[:collection_dids]).to eq collections.map(&:did)
    end
  end

  describe "#project" do 

    after(:each) { ActiveFedora::Base.delete_all } 

    it "returns nil for CoreFiles that belong to no collections" do 
      expect(core_file.project).to be nil
    end

    it "returns nil for CoreFiles that belong to orphaned collections" do 
      core_file.collections << collection
      core_file.save! 

      expect(core_file.project).to be nil
    end

    it "returns a project for CoreFiles that belong to an OK collection" do 
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
      tei  = FactoryGirl.create :tei_file
      core_file.tfc << tei ; core_file.save! 
      expect(tei.tfc_for).to match_array [core_file]
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
    it { respond_to :placeography_for } 
    it { respond_to :placeography_for= }

    after(:each) { ActiveFedora::Base.delete_all }

    it "are manipulated as arrays" do 
      other_collection = FactoryGirl.create :collection

      core_file.otherography_for << collection
      core_file.otherography_for << other_collection 

      expect(core_file.otherography_for).to match_array [collection, other_collection]

      core_file.otherography_for = [collection]

      expect(core_file.otherography_for).to match_array [collection]
    end
  end

  describe "Page Image relationships" do 
    it { respond_to :page_images }
    it { respond_to :page_images= }

    after(:each) { ActiveFedora::Base.delete_all }

    it "can be set on the Core File object but are written to the IMF" do 
      imf = FactoryGirl.create :image_master_file

      expect(core_file.page_images).to eq []

      core_file.page_images << imf 
      core_file.save!

      expect(imf.page_image_for.first.pid).to eq core_file.pid
    end
  end

  describe "HTML Object Queries" do 
    before(:each) { setup_html_tests }
    after(:each) { core_file.destroy } 

    def setup_html_tests
      @teibp = FactoryGirl.create :html_file
      @teibp.html_for << core_file 
      @teibp.core_file = core_file
      @teibp.html_type = "teibp"
      @teibp.save!

      @tapas_generic = FactoryGirl.create :html_file
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

  describe "#file_type" do 
    after(:each) { ActiveFedora::Base.delete_all } 

    it 'returns :ography for files that have a specified ography type' do 
      CoreFile.all_ography_read_methods.each do |ography|
        core_file.send(:"#{ography}=", [collection])
        expect(core_file.file_type).to eq :ography
        core_file.clear_ographies!
      end
    end

    it 'returns :tei_content for files with no specified ography type' do 
      expect(core_file.file_type).to eq :tei_content
    end
  end

  describe "#clear_ographies!" do 
    after(:each) { ActiveFedora::Base.delete_all } 

    it 'clears all set ographies' do 
      core_file.personography_for << collection
      core_file.orgography_for << collection
      core_file.bibliography_for << collection
      core_file.otherography_for << collection 
      core_file.odd_file_for << collection
      core_file.placeography_for << collection

      core_file.clear_ographies! 

      any_ographies = CoreFile.all_ography_read_methods.any? do |ography_type|
        core_file.send(ography_type).any?
      end

      expect(any_ographies).to be false
    end
  end

  describe '#calculate_drupal_access' do 
    after(:all) { ActiveFedora::Base.delete_all } 

    it 'saves the object as private if it has no collections' do 
      core_file.save!
      expect(core_file.drupal_access).to eq 'private'
    end

    it 'saves the object as public if it has a single public collection' do 
      c1, c2, c3 = FactoryGirl.create_list :collection, 3
      c1.drupal_access = 'private' ; c1.save!
      c1.drupal_access = 'private' ; c2.save! 
      c3.drupal_access = 'public'  ; c3.save! 

      core_file.collections = [c1, c2, c3]
      core_file.save!
      expect(core_file.drupal_access).to eq 'public'
    end

    it 'saves the object as private if it has all private collections' do 
      collections = FactoryGirl.create_list :collection, 2
      collections.each do |collection|
        collection.drupal_access = 'private' 
        collection.save!
      end

      core_file.collections = collections
      core_file.save!
      expect(core_file.drupal_access).to eq 'private'
    end
  end
end
