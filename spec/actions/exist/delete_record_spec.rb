require 'spec_helper'

describe Exist::DeleteRecord do
  include FileHelpers

  before(:all) do
    community = FactoryGirl.create :community
    community.did = community.pid
    community.save!
    collection = FactoryGirl.create :collection
    collection.community = community
    collection.did = collection.pid
    collection.save!

    @core_file = FactoryGirl.create :core_file
    @core_file.collections << collection
    @core_file.save!

    @core_file_non_indexed = FactoryGirl.create :core_file
    @core_file_non_indexed.collections << collection
    @core_file_non_indexed.save!
  end

  it 'returns a 500 for dids that are not indexed in exist' do
    e = RestClient::InternalServerError
    bad_did = @core_file_non_indexed.did
    expect { Exist::DeleteRecord.execute(bad_did) }.to raise_error e
  end


  it 'returns a 200 when a record is successfully deleted' do
    Exist::StoreTei.execute(fixture_file('tei.xml'), @core_file)
    response = Exist::DeleteRecord.execute(@core_file.did)
    expect(response.code).to eq 200
  end
end
