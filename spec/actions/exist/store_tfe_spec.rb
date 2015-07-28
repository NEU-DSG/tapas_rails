require 'spec_helper' 

describe Exist::StoreTfe do
  include FileHelpers

  it 'raises an error when a did that is not in Exist yet is used' do 
    did = SecureRandom.uuid 
    e = RestClient::BadRequest
    expect { Exist::StoreTfe.execute(did,'11','111','false') }.to raise_error e
  end

  it 'raises an error when is_public is not set to a boolean value' do 
    did = SecureRandom.uuid
    e = RestClient::BadRequest
    expect { Exist::StoreTfe.execute(did, '1', '3,4', 'pub') }.to raise_error e
  end

  it 'returns a 200 when TFE is correctly added to an existing TEI document' do 
    tei = fixture_file 'tei.xml'
    did = SecureRandom.uuid 
    Exist::StoreTei.execute(tei, did)
    response = Exist::StoreTfe.execute(did, '1', '3, 5, 6', 'true')
    expect(response.status).to eq 200 
  end
end
