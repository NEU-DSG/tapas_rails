require 'spec_helper'

describe CoreFileValidator do 
  include ValidatorHelpers
  include FixtureBuilders
  include FileHelpers

  # Sets up a valid repository structure
  before(:all) do 
    @core_file, @collections, @project = FixtureBuilders.create_all 2
  end

  let(:valid_params_all) do
    { :depositor => 'test_depositor',
      :did => SecureRandom.uuid, 
      :file_types => ['personography'], #Indicates a file that is tei content only
      :tei => Rack::Test::UploadedFile.new(
        fixture_file('tei.xml'),
        'application/xml'),
      :collection_dids => @collections.map(&:did),
      :display_title => "A Valid Display Title", 
      :display_authors => ['Mickey', 'Minnie', 'Goofie'],
      :display_contributors => ['Donald', 'Scrooge'],
      :display_date => DateTime.now.iso8601.to_s, 
      :support_files => Rack::Test::UploadedFile.new(
        fixture_file('all_files.zip'),
        'application/zip') }
  end

  def validate_with_params(params)
    return CoreFileValidator.validate_upsert(params)
  end

  context 'Create with all valid params' do 
    it 'raises no errors' do 
      errors = validate_with_params(valid_params_all)
      expect(errors.length).to eq 0
    end
  end

  context 'Update with all valid params' do 
    it 'raises no errors' do 
      valid_params_all[:did] = @core_file.did 
      errors = validate_with_params(valid_params_all.except(:collection_dids,
                                                            :depositor, 
                                                            :tei))
      expect(errors.length).to eq 0
    end
  end

  context 'Create with invalid data' do 

  end

  context 'Update with invalid data' do 

  end
end
