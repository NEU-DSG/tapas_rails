require 'spec_helper' 

describe Exist::StoreTei do 
  include FileHelpers

  it 'returns a 201 for valid uploads' do 
    file = fixture_file 'tei.xml' 
    did  = SecureRandom.uuid
    response = Exist::StoreTei.execute(file, did) 
    expect(response.code).to eq 201

    Exist::DeleteRecord.execute(did)
  end
end
