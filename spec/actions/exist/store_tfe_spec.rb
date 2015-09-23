require 'spec_helper' 

describe Exist::StoreTfe do
  include FileHelpers
  include FixtureBuilders

  before(:all) do 
    @core_file, @collections, @community = FixtureBuilders.create_all

    @core_file_unindexed = FactoryGirl.create :core_file
    @core_file_unindexed.collections = @collections
    @core_file_unindexed.save!

    Exist::StoreTei.execute(fixture_file('tei.xml'), @core_file.did)
  end

  after(:all) { ActiveFedora::Base.delete_all }

  it 'raises an error when a did that is not in Exist yet is used' do 
    e = RestClient::InternalServerError
    expect { Exist::StoreTfe.execute(@core_file_unindexed) }.to raise_error e
  end

  it 'raises an error when an incomplete core file is passed' do 
    # Index an incomplete core_file
    core = FactoryGirl.create :core_file 
    Exist::StoreTei.execute(fixture_file('tei.xml'), core.did)

    e = RestClient::InternalServerError
    expect { Exist::StoreTfe.execute(core) }.to raise_error e
  end

  it 'returns a 201 when TFE is correctly added to an existing TEI document' do 
    response = Exist::StoreTfe.execute(@core_file)
    expect(response.code).to eq 201
  end
end
