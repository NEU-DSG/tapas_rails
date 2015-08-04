require 'spec_helper'

describe Collection do 
  describe "Core File drupal access" do 
    let(:coll) { FactoryGirl.create(:collection) }

    after(:each) { ActiveFedora::Base.delete_all }
    
    context "on a collection that has been made public" do 
      it 'is set to public' do 
        one, two = FactoryGirl.create_list(:core_file, 2)
        one.drupal_access = 'private' ; one.collections << coll ; one.save!
        two.drupal_access = 'private' ; two.collections << coll ; two.save!
        expect(one.reload.drupal_access).to eq 'private'
        expect(two.reload.drupal_access).to eq 'private' 

        coll.drupal_access = 'public'
        coll.save! 

        expect(one.reload.drupal_access).to eq 'public' 
        expect(two.reload.drupal_access).to eq 'public'
      end
    end

    context "on a collection that has been made private" do 
      it 'is set to private unless the object has other public collections' do
        one, two = FactoryGirl.create_list(:core_file, 2)

        public_collection = FactoryGirl.create(:collection)
        public_collection.drupal_access = 'public' 
        public_collection.save! 

        private_collection = FactoryGirl.create(:collection) 
        private_collection.drupal_access = 'private' 
        private_collection.save! 

        one.collections = [coll, public_collection] 
        one.drupal_access = 'public' 
        one.save!

        two.collections = [coll, private_collection] 
        two.drupal_access = 'public' 
        two.save!

        coll.drupal_access = 'private'
        coll.save!

        expect(one.reload.drupal_access).to eq 'public' 
        expect(two.reload.drupal_access).to eq 'private'
      end
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
    it { respond_to :placeographies }
    it { respond_to :placeographies= }

    it "can be set on core files from the collection" do 
      collection = FactoryGirl.create :collection
      core_file = FactoryGirl.create :core_file

      collection.orgographies << core_file
      collection.save!

      expect(core_file.orgography_for.first.pid).to eq collection.pid
      expect(collection.reload.orgographies).to match_array [core_file]
    end
  end

  it_behaves_like 'InlineThumbnails'
end
