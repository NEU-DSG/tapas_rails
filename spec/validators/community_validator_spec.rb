require 'spec_helper'

describe CommunityValidator do 
  include ValidatorHelpers

  describe '#validate_required_attributes' do 

    def validate_attributes(params, create_or_update)
      validator = CommunityValidator.new params
      validator.create_or_update = create_or_update
      validator.validate_required_attributes
      validator.errors
    end

    context 'on create' do 
      let(:params) do 
        { :members => %w(peter paul mary),
          :depositor => 'bjork', 
          :access => 'public', 
          :title => 'A Sample Project', 
          :description => 'A sample project.', }
      end

      it 'requires members' do 
        errors = validate_attributes(params.except(:members), :create)
        expect(errors.length).to eq 1 
        expect(errors.first).to include 'members'
      end

      it 'requires a depositor' do 
        errors = validate_attributes(params.except(:depositor), :create)
        expect(errors.length).to eq 1
        expect(errors.first).to include 'depositor'
      end

      it 'requires an access level' do 
        errors = validate_attributes(params.except(:access), :create)
        expect(errors.length).to eq 1 
        expect(errors.first).to include 'access'
      end

      it 'requires a title' do 
        errors = validate_attributes(params.except(:title), :create) 
        expect(errors.length).to eq 1 
        expect(errors.first).to include 'title' 
      end

      it 'requires a description' do 
        errors = validate_attributes(params.except(:description), :create)
        expect(errors.length).to eq 1 
        expect(errors.first).to include 'description'
      end
    end

    context 'on update' do 
      it 'requires no params' do 
        errors = validate_attributes({}, :update)
        expect(errors.length).to eq 0
      end
    end
  end
end
