require 'spec_helper'

describe Collection do 
  describe "Core File drupal access" do 
    let(:coll) { FactoryGirl.create(:collection) }
    
    context "on a collection that has been made public" do 
      
      it 'is set to public' do 
        one, two = FactoryGirl.create_list(:core_file, 2)
        one.drupal_access = 'private' ; one.collection = coll ; one.save!
        two.drupal_access = 'private' ; two.collection = coll ; two.save! 

        expect(one.reload.drupal_access).to eq 'private'
        expect(two.reload.drupal_access).to eq 'private' 

        coll.drupal_access = 'public'
        coll.save! 

        expect(one.reload.drupal_access).to eq 'public' 
        expect(two.reload.drupal_access).to eq 'public'
      end
    end

    context "on a collection that has been made private" do 

    end
  end

  describe "phantom collection" do 
    let(:phantom) { Collection.phantom_collection }

    before(:each) { Collection.destroy_all }
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
