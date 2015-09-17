require 'spec_helper' 

describe Exist::StoreTei do 
  include FileHelpers

  it 'returns a 201 for valid uploads' do 
    file = fixture_file 'tei.xml' 
    
    community = FactoryGirl.create :community

    collection = FactoryGirl.create :collection
    collection.community = community 
    collection.save!

    core_file = FactoryGirl.create :core_file 
    core_file.collections << collection
    core_file.save!

    did  = core_file.did
    response = Exist::StoreTei.execute(file, did) 
    expect(response.code).to eq 201
  end
end
