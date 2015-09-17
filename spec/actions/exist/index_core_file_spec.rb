require 'spec_helper'

describe Exist::IndexCoreFile do 
  include FileHelpers

  describe "With a filepath" do 
    before(:all) do 
      @community = FactoryGirl.create :community

      puts @community.did

      @collection = FactoryGirl.create :collection
      @collection.community = @community
      @collection.save! 

      @core_file = FactoryGirl.create :core_file
      @core_file.collections << @collection
      @core_file.save!

      puts @core_file.did

      @filepath = fixture_file 'tei.xml'
    end

    # This test needs to be improved ASAP.
    it 'returns no errors on valid requests' do 
      expect { Exist::IndexCoreFile.execute(@core_file, @filepath) }.not_to raise_error
    end
  end
end
