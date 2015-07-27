require 'spec_helper' 

describe Exist::DeleteRecord do 

  it 'raises an error for dids that are not indexed in exist' do 
    e = RestClient::BadRequest
    expect { Exist::DeleteRecord.execute(SecureRandom.uuid) }.to raise_error e
  end

  it 'successfully deletes records that are indexed in exist' do 
    pending 'Need to have a way to put records in exist that works' 
  end
end
