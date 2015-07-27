require 'spec_helper' 

describe Exist::GetMods, :existdb => true do
  include FileHelpers

  describe '#execute' do 
    it 'raises an error when passed a bad path' do 
      error = Errno::ENOENT
      expect { Exist::GetMods.execute('no/such/file') }.to raise_error error
    end

    it 'raises a 400 when given a file that is not TEI XML' do 
      path = fixture_file 'image.jpg' 
      error = RestClient::BadRequest
      expect { Exist::GetMods.execute path  }.to raise_error error
    end

    it 'returns a MODS document when given valid TEI XML' do 
      path = fixture_file 'tei.xml'
      expect { Exist::GetMods.execute path  }.not_to raise_error
      response = Exist::GetMods.execute path 
      expect { Nokogiri::XML(response) { |c| c.strict } }.not_to raise_error
    end
  end
end