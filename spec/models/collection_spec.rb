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
end
