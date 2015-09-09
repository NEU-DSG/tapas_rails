require 'spec_helper' 

describe Exist::GetMods, :existdb => true do
  include FileHelpers

  describe '#execute' do 
    context 'with no optional arguments' do 
      it 'raises a 400 when given a file that is not TEI XML' do 
        path = fixture_file 'xml_malformed.xml'
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

    context 'with display parameters' do 
      let(:path) { fixture_file 'tei.xml' } 

      it 'passes valid display params to eXist' do 
        authors = %w(Peter Paul Mary)
        contributors = %w(Jack Jill)
        title = 'Testing valid display params'
        date = Time.now.iso8601

        opts = { authors: authors, contributors: contributors, 
                 date: date, title: title }
        response = Exist::GetMods.execute(path, opts)

        # While we don't want to write tests that test against the exact
        # structure of the XML that eXist returns (too fragile), we should
        # at least make sure that our additional params are in some way 
        # making it into the returned XML document.
        expect(authors.all? { |a| response.include? a }.to be true)
        expect(contributors.all? { |c| response.include? c }.to be true)
        expect(response.include? title).to be true 
        expect(response.include? date).to be true
      end

      it 'ignores invalid display params' do 
        opts = { authors: ['Squilliam Tentacles'], abstract: 'Foobar' }
        response = Exist::GetMods.execute(path, opts)
        expect(opts[:authors].all? { |a| response.include? a }).to be true
        expect(response.include? opts[:abstract]).to be false
      end
    end
  end
end
