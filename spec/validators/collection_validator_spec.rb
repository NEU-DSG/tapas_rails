require 'spec_helper'

describe CollectionValidator do 
  include ValidatorHelpers

  describe '#validate_required_attributes' do 

    def validate_attributes(params, create_or_update)
      validator = CollectionValidator.new(params)
      validator.create_or_update = create_or_update
      validator.validate_required_attributes
      validator.errors 
    end


    context 'on create' do 
      let(:params) do
        { title: "Sample Collection", 
          description: "A sample collection", 
          depositor: "test", 
          access: "public", 
          project_did: "455" }
      end

      it "raises an error with no title" do 
        errors = validate_attributes(params.except(:title), :create)
        expect(errors.length).to eq 1 
      end

      it "raises an error with no description" do 
        errors = validate_attributes(params.except(:description), :create)
        expect(errors.length).to eq 1
      end

      it 'raises an error with depositor' do 
        errors = validate_attributes(params.except(:depositor), :create)
        expect(errors.length).to eq 1 
      end

      it 'raises an error with no access param' do 
        errors = validate_attributes(params.except(:access), :create)
        expect(errors.length).to eq 1 
      end

      it 'raises an error with no project_did' do 
        errors = validate_attributes(params.except(:project_did), :create)
        expect(errors.length).to eq 1 
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
