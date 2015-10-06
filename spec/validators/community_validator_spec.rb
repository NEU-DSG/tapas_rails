require 'spec_helper'

describe CommunityValidator do 
  include ValidatorHelpers

  def validate_attributes(params)
    validator = CommunityValidator.new params
    validator.validate_upsert
  end

  context 'on create' do 
    let(:params) do 
      { :members => %w(peter paul mary),
        :did => SecureRandom.uuid,
        :depositor => 'bjork', 
        :access => 'public', 
        :title => 'A Sample Project', 
        :description => 'A sample project.', }
    end

    it 'requires members' do 
      errors = validate_attributes(params.except(:members))
      expect(errors.length).to eq 1 
      expect(errors.first).to include 'members'
    end

    it 'requires a depositor' do 
      errors = validate_attributes(params.except(:depositor))
      expect(errors.length).to eq 1
      expect(errors.first).to include 'depositor'
    end

    it 'requires an access level' do 
      errors = validate_attributes(params.except(:access))
      expect(errors.length).to eq 1 
      expect(errors.first).to include 'access'
    end

    it 'requires a title' do 
      errors = validate_attributes(params.except(:title))
      expect(errors.length).to eq 1 
      expect(errors.first).to include 'title' 
    end

    it 'requires a description' do 
      errors = validate_attributes(params.except(:description))
      expect(errors.length).to eq 1 
      expect(errors.first).to include 'description'
    end
  end

  context 'on update' do 
    before(:all) do 
      @community = FactoryGirl.create :community
    end

    after(:all) { @community.destroy }

    it 'requires no params' do 
      errors = validate_attributes({:did => @community.did})
      expect(errors.length).to eq 0
    end
  end
end
