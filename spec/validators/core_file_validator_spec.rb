require 'spec_helper'

describe CoreFileValidator do
  include ValidatorHelpers
  include FixtureBuilders
  include FileHelpers

  # Sets up a valid repository structure
  before(:all) do
    @core_file, @collections, @project = FixtureBuilders.create_all 2
    @core_file, @other_collection, @other_project = FixtureBuilders.create_all
  end

  before(:each) { @errors = nil }

  def params
    { :depositor => 'test_depositor',
      :did => 'test_did',
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

  context 'Create with all valid params' do
    it 'raises no errors' do
      validate(params)
      expect(@errors.length).to eq 0
    end
  end

  context 'Update with all valid params' do
    it 'raises no errors' do
      removed = %i(collection_dids depositor tei file_types)
      valid = params.except removed
      valid[:did] = @core_file.did

      validate(valid)
      expect(@errors.length).to eq 0
    end
  end

  context 'Create with missing required data' do
    it 'raises an error when tei is missing' do
      validate(params.except(:tei))
      expect(@errors.length).to eq 1
    end

    it 'raises an error when depositor is missing' do
      validate(params.except(:depositor))
      expect(@errors.length).to eq 1
    end

    it 'raises an error when collection_dids is missing' do
      validate(params.except(:collection_dids))
      expect(@errors.length).to eq 1
    end
  end

  context 'Update with invalid params' do
    before(:each) do
      params[:did] = @core_file.did
    end

    it 'raises an error when display_date is not an iso8601 date' do
      validate(params.merge(:display_date => 'Jan 12, 1901'))
      it_raises_a_single_error('display_date must be ISO8601 formatted')
    end

    it 'raises an error when file_types is not an array' do
      validate(params.merge(:file_types => 'personography'))
      it_raises_a_single_error('file_types must be an array')
    end

    it 'raises an error when an invalid file_type is passed' do
      validate(params.merge(:file_types => ['bobography']))
      it_raises_a_single_error("bobography is not a valid option")
    end

    it 'raises an error when collection_dids is not an array' do
      validate(params.merge(:collection_dids => '1'))
      it_raises_a_single_error('collection_dids must be an array')
    end

    it 'raises an error when collection_dids references nonexistent collections' do
      validate(params.merge(collection_dids: ['111-111']))
      it_raises_a_single_error('collections that do not exist')
    end

    it 'raises an error when collection_dids references collections that '\
      'belong to multiple projects' do
      collections = (@collections + @other_collection).map(&:did)
      validate(params.merge collection_dids: collections)

      it_raises_a_single_error('collections that belong to multiple projects')
    end
  end
end
