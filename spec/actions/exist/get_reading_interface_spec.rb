require 'spec_helper' 

describe Exist::GetReadingInterface, :existdb => true do 
  include FileHelpers

  it 'raises a 400 when passed an invalid reading interface type' do 
    path = fixture_file 'tei.xml'
    e = Exceptions::ExistError
    expect { Exist::GetReadingInterface.execute(path, 'x') }.to raise_error e
  end

  pending 'write tests for validity once we are sure that exist is dtrt' 
end
    
