require 'spec_helper' 

describe Exist::StoreTei do 
  include FileHelpers

  it 'returns a 200 for valid uploads' do 
    file = fixture_file 'tei.xml' 
    did  = SecureRandom.did 
    response = Exist::StoreTei.execute(file, did) 
    expect(response.status).to eq 200 
  end
end
