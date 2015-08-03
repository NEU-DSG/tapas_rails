require 'spec_helper'

describe UpsertCollection do
  def params
    { :did => '111',
      :description => 'This is a test collection',
      :depositor => '011', 
      :title => 'A Test Collection',
      :access => 'public',
      :project_did => '333'
    }
  end

  def build_parent_community
    @community = Community.new
    @community.did = params[:project_did]
    @community.save!
  end

  subject(:collection) { Collection.find_by_did(params[:did]) } 

  RSpec.shared_examples 'a metadata assigning operation' do 
    its('mods.title') { should eq [params[:title]] }
    its('mods.abstract') { should eq [params[:description]] }
    its(:drupal_access) { should eq params[:access] } 
    its(:mass_permissions) { should eq 'private' }
  end

  context 'When creating a collection' do 
    context 'with a preexisting community.' do 
      before(:all) do 
        build_parent_community
        UpsertCollection.upsert params
      end

      after(:all) { ActiveFedora::Base.delete_all } 

      it 'builds the requested collection' do 
        expect(collection.class).to eq Collection
      end

      it 'attaches it to the requested community' do 
        expect(collection.community.pid).to eq @community.pid 
      end

      it 'assigns a depositor' do 
        expect(collection.depositor).to eq params[:depositor]
      end

      it 'assigns the og_reference attribute' do 
        expect(collection.og_reference).to eq [params[:project_did]]
      end

      it_should_behave_like 'a metadata assigning operation' 
    end

    context 'without a preexisting community.' do 
      before(:all) { UpsertCollection.upsert params } 
      after(:all) { ActiveFedora::Base.delete_all } 
      it 'assigns the collection to the phantom collection bucket' do 
        pid = Rails.configuration.phantom_collection_pid
        expect(collection.community).to be nil
        expect(collection.collection.pid).to eq pid
      end

      it_should_behave_like 'a metadata assigning operation'
    end
  end

  context 'when updating a collection that already exists' do 
    before(:all) do 
      build_parent_community
      collection = Collection.new
      collection.did = params[:did]
      collection.depositor = 'Old Depositor'
      collection.save!
      collection.community = FactoryGirl.create(:community)
      collection.og_reference = [collection.community.did]
      collection.save!

      UpsertCollection.upsert params
    end

    after(:all) { ActiveFedora::Base.delete_all } 

    it 'does not update the depositor even if a new one is provided' do
      expect(collection.depositor).to eq 'Old Depositor'
    end

    it 'does not update the containing project even if a new one is provided' do
      expect(collection.community.pid).not_to eq @community.pid 
    end

    it 'does not update the og reference even if a new one is provided' do 
      expect(collection.og_reference).to eq [collection.community.did]
    end

    it 'does not rebuild the collection' do 
      expect(Collection.all.length).to eq 1 
    end

    it_should_behave_like 'a metadata assigning operation' 
  end
end
