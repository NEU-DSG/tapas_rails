require 'spec_helper'

describe CollectionValidator do 
  include ValidatorHelpers
  include FileHelpers

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
      expect(validate(params).length).to eq 0 
    end
  end

  context 'update with valid data' do 
    before(:all) { @collection = FactoryGirl.create :collection } 
    after(:all) { @collection.destroy }

    it 'raises no errors' do 
      update_params = {:did => @collection.did }
      expect(validate(update_params).length).to eq 0 
    end
  end

  context 'create with missing required params' do 
    it "raises an error with no title" do 
      validate(params.except(:title))
      expect(@errors.length).to eq 1 
    end

    it "raises an error with no description" do 
      validate(params.except(:description))
      expect(@errors.length).to eq 1
    end

    it 'raises an error with depositor' do 
      validate(params.except(:depositor))
      expect(@errors.length).to eq 1 
    end

    it 'raises an error with no access param' do 
      validate(params.except(:access))
      expect(@errors.length).to eq 1 
    end

    it 'raises an error with no project_did' do 
      validate(params.except(:project_did))
      expect(@errors.length).to eq 1 
    end
  end

  context 'create with invalid data' do 
    it 'raises an error when a bad project_did is passed' do 
      validate(params.merge(project_did: SecureRandom.uuid))
      it_raises_a_single_error 'project with specified did'
    end
  end
end
