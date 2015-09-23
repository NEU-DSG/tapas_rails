require 'spec_helper'

describe Exist::IndexCoreFile do 
  include FileHelpers
  include FixtureBuilders

  describe "With a filepath" do 
    before(:all) do 
      @core_file, @collections, @community = FixtureBuilders.create_all
      @filepath = fixture_file 'tei.xml'
    end

    # This test needs to be improved ASAP.
    it 'returns no errors on valid requests' do 
      expect { Exist::IndexCoreFile.execute(@core_file, @filepath) }.not_to raise_error
    end
  end
end
