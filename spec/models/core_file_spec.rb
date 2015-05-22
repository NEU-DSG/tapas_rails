require "spec_helper" 

describe CoreFile do 
  describe "Ography relationships" do 
    it { respond_to :xography_for= }
    it { respond_to :xography_for }
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

        core.xography_for << collection
        core.xography_for << other_collection 

        expect(core.xography_for).to match_array [collection, other_collection]

        core.xography_for = [collection]

        expect(core.xography_for).to match_array [collection]
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
end
