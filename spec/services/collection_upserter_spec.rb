require 'spec_helper'

describe CollectionUpserter do 
  def params
    { :did => "111",
      :depositor => "011", 
      :title => "A Test Collection",
      :access => "public",
      :project => "333"
    }
  end

  def build_parent_community
    @community = Community.new
    @community.did = params[:project]
    @community.save!
  end

  subject(:collection) { Collection.find_by_did(params[:did]) } 

  RSpec.shared_examples "a metadata assigning operation" do 
    its("mods.title") { should eq [params[:title]] }
    its(:depositor)   { should eq params[:depositor] } 
    its(:drupal_access) { should eq params[:access] } 
    its(:og_reference) { should eq params[:project] } 
  end

  context "When creating a collection" do 
    context "with a preexisting community." do 
      before(:all) do 
        build_parent_community
        CollectionUpserter.upsert params
      end

      after(:all) { ActiveFedora::Base.delete_all } 

      it "builds the requested collection" do 
        expect(collection.class).to eq Collection
      end

      it "attaches it to the requested community" do 
        expect(collection.community.pid).to eq @community.pid 
      end

      it_should_behave_like "a metadata assigning operation" 
    end

    context "without a preexisting community." do 
      before(:all) { CollectionUpserter.upsert params } 
      after(:all) { ActiveFedora::Base.delete_all } 
      it "assigns the collection to the phantom collection bucket" do 
        pid = Rails.configuration.phantom_collection_pid
        expect(collection.community).to be nil
        expect(collection.collection.pid).to eq pid
      end

      it_should_behave_like "a metadata assigning operation"
    end
  end

  context "when updating a collection that already exists" do 
    before(:all) do 
      build_parent_community
      collection_old = Collection.new
      collection_old.did = params[:did]
      collection_old.depositor = "#{params[:depositor]}_old"
      collection_old.save!

      CollectionUpserter.upsert params
    end

    after(:all) { ActiveFedora::Base.delete_all } 

    it "doesn't rebuild the collection" do 
      expect(Collection.all.length).to eq 1 
    end

    it_should_behave_like "a metadata assigning operation" 
  end
end
