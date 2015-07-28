require 'spec_helper' 

describe Exist::DeleteRecord do 
  include FileHelpers

  it 'returns a 404 for dids that are not indexed in exist' do 
    e = RestClient::BadRequest 
    expect { Exist::DeleteRecord.execute(SecureRandom.uuid) }.to raise_error e
  end


  it 'returns a 200 when a record is successfully deleted' do 
    did = SecureRandom.uuid
    Exist::StoreTei.execute(fixture_file('tei.xml'), did)

    response = Exist::DeleteRecord.execute(did)
    expect(response.code).to eq 200 
  end
end
