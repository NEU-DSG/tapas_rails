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

    response = Exist::StoreMods.execute(file, @core_file)
    expect(response.code).to eq 201
  end

  it 'passes optional params correctly' do 
    file = fixture_file 'tei.xml' 
    Exist::StoreTei.execute(file, @core_file.did) 

    opts = { 
      :authors => ['Bob Jenkins'],
      :contributors => ['Cotton Mathers'],
      :date => Time.now.iso8601, 
      :title => 'Test Store Mods Request'
    }

    response = Exist::StoreMods.execute(file, @core_file, opts)

    expect(response.code).to eq 201
    expect(response.include?(opts[:authors].first)).to be true
    expect(response.include?(opts[:contributors].first)).to be true
    expect(response.include?(opts[:date].first)).to be true
    expect(response.include?(opts[:title].first)).to be true
  end
end
