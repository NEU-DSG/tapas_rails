require 'spec_helper'

describe Collection do 
  describe "phantom collection" do 
    let(:phantom) { Collection.phantom_collection }

    after(:each) { Collection.destroy_all }

    it "is created when referenced before existence" do 
      phid = Rails.configuration.phantom_collection_pid
      expect(Collection.exists? phid).to be false 
      phantom
      expect(Collection.exists? phid).to be true
    end

    it "is looked up when it exists and not created anew" do 
      Collection.phantom_collection ; Collection.phantom_collection
      expect(Collection.count).to eq 1 
    end
  end

  describe "Ography relationships" do 
    it { respond_to :xographies }
    it { respond_to :personographies } 
    it { respond_to :orgographies } 
    it { respond_to :bibliographies }
    it { respond_to :otherographies } 
    it { respond_to :odd_files }
    it { respond_to :xographies= }
    it { respond_to :personographies= }
    it { respond_to :orgographies= }
    it { respond_to :bibliographies= }
    it { respond_to :otherographies= }
    it { respond_to :odd_files= }

    it "can be set on core files from the collection" do 
      begin
        collection = Collection.create(:depositor => "x", :did => "y")
        core_file = CoreFile.create(:depositor => "x", :did => "z")

        collection.orgographies << core_file
        collection.save!

        expect(core_file.orgography_for.first.pid).to eq collection.pid
      ensure
        collection.delete if collection.persisted?
        core_file.delete if core_file.persisted?
      end
    end
  end
end
