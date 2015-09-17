require 'spec_helper'

describe Exist::StoreMods do 
  include FileHelpers

  before(:all) do 
    @community = FactoryGirl.create :community

    @collection = FactoryGirl.create :collection
    @collection.community = @community
    @collection.save!

    @core_file = FactoryGirl.create :core_file 
    @core_file.collections << @collection 
    @core_file.save! 
  end

  it 'returns a 201 for valid storage requests' do 
    file = fixture_file 'tei.xml' 
    Exist::StoreTei.execute(file, @core_file.did)

    response = Exist::StoreMods.execute(@core_file, file)
    expect(response.code).to eq 201
  end
end
