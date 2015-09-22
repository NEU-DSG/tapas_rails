require 'spec_helper' 

describe Exist::StoreTfe do
  include FileHelpers

  before(:all) do 
    @community = FactoryGirl.create :community

    @collection = FactoryGirl.create :collection
    @collection.community = @community
    @collection.save! 

    @core_file = FactoryGirl.create :core_file 
    @core_file.collections << @collection 
    @core_file.save! 

    @core_file_unindexed = FactoryGirl.create :core_file
    @core_file_unindexed.collections << @collection 
    @core_file_unindexed.save!
  end

  it 'raises an error when a did that is not in Exist yet is used' do 
    did = @core_file_unindexed.did
    e = RestClient::InternalServerError
    expect { Exist::StoreTfe.execute(did,'11','111','false') }.to raise_error e
  end

  it 'raises an error when is_public is not set to a boolean value' do 
    did = @core_file.did
    e = RestClient::InternalServerError
    expect { Exist::StoreTfe.execute(did, '1', '3,4', 'pub') }.to raise_error e
  end

  it 'returns a 201 when TFE is correctly added to an existing TEI document' do 
    tei = fixture_file 'tei.xml'
    Exist::StoreTei.execute(tei, @core_file.did)
    response = Exist::StoreTfe.execute(@core_file.did,
                                       @community.did, 
                                       @core_file.collections.map { |x| x.did }, 
                                       'true')
    expect(response.code).to eq 201
  end
end
