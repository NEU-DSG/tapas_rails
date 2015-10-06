require 'spec_helper'

describe CollectionValidator do 
  include ValidatorHelpers
  include FileHelpers

  def validate_attributes(params)
    CollectionValidator.validate_upsert(params)
  end

  before(:all) do 
    @community = FactoryGirl.create :community 
  end

  after(:all) { @community.destroy }

  let(:params) do
    { title: "Sample Collection",
      did: SecureRandom.uuid,
      description: "A sample collection", 
      depositor: "test", 
      access: "public", 
      project_did: @community.did, 
      thumbnail: Rack::Test::UploadedFile.new(
        fixture_file('image.jpg'), 'image/jpeg'
      ) }
  end

  context 'create with valid data' do 
    it 'raises no errors' do 
      expect(validate_attributes(params).length).to eq 0 
    end
  end

  context 'update with valid data' do 
    before(:all) { @collection = FactoryGirl.create :collection } 
    after(:all) { @collection.destroy }

    it 'raises no errors' do 
      update_params = {:did => @collection.did }
      expect(validate_attributes(update_params).length).to eq 0 
    end
  end

  context 'create with missing required params' do 
    it "raises an error with no title" do 
      errors = validate_attributes(params.except(:title))
      expect(errors.length).to eq 1 
    end

    it "raises an error with no description" do 
      errors = validate_attributes(params.except(:description))
      expect(errors.length).to eq 1
    end

    it 'raises an error with depositor' do 
      errors = validate_attributes(params.except(:depositor))
      expect(errors.length).to eq 1 
    end

    it 'raises an error with no access param' do 
      errors = validate_attributes(params.except(:access))
      expect(errors.length).to eq 1 
    end

    it 'raises an error with no project_did' do 
      errors = validate_attributes(params.except(:project_did))
      expect(errors.length).to eq 1 
    end
  end

  context 'create with invalid data' do 
    it 'raises an error when a bad project_did is passed' do 
      errors = validate_attributes(params.merge(project_did: SecureRandom.uuid))
      expect(errors.length).to eq 1
      expect(errors.first).to include 'project with specified did' 
    end
  end
end
