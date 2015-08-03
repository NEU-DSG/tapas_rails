require 'spec_helper'

describe CoreFileValidator do 
  include ValidatorHelpers
  include FileHelpers


  describe '#validate_file_type' do 
    let(:params) do
      { :tei => 'file.xml', :depositor => 'test' }
    end

    def validate_file_type(params, create_or_update)
      validator = CoreFileValidator.new params 
      validator.create_or_update = create_or_update 
      validator.validate_file_type
      validator
    end

    it "raises an error when no file_type is specified" do 
      params.merge!(:collection_dids => [1, 2], :project_did => 3)
      validator = validate_file_type(params, :create)
      expect(validator.errors.length).to eq 1
    end

    context 'when creating a TEI Content file' do 
      it 'raises an error if no collection_dids are specified' do 
        params.merge!(:file_type => 'tei_content', :project_did => '111')
        validator = validate_file_type(params, :create)
        expect(validator.errors.length).to eq 1
      end

      it 'raises no errors if collection_dids is specified' do 
        params.merge!(:file_type => 'tei_content', 
                      :collection_dids => ['1', '2', '3'])
        validator = validate_file_type(params, :create)
        expect(validator.errors.length).to eq 0
      end

      context 'when creating an ography' do 
        it 'raises an error if no project_did is specified' do 
          params.merge!(:file_type => 'ography', :collection_dids => [1])
          validator = validate_file_type(params, :create)
          expect(validator.errors.length).to eq 1
        end

        it 'raises no error if project_did is specified' do 
          params.merge!(:file_type => 'ography', :project_did => '111')
          validator = validate_file_type(params, :create) 
          expect(validator.errors.length).to eq 0
        end
      end

      context 'when updating a TEI Content file' do 
        it 'raises no errors' do 
          params.merge!(:file_type => 'tei_content', :project_did => '111')
          validator = validate_file_type(params, :update)
          expect(validator.errors.length).to eq 0 
        end
      end

      context 'when updating an ography' do 
        it 'raises no errors' do 
          params.merge!(:file_type => 'ography', :project_did => '123') 
          validator = validate_file_type(params, :update)
          expect(validator.errors.length).to eq 0 
        end
      end
    end

    describe '#validate_required_attributes' do 
      context "on update" do 
        it 'does not require any params' do 
          params = {}
          validator = CoreFileValidator.new(params)
          validator.create_or_update = :update 
          validator.validate_required_attributes
          expect(validator.errors.length).to eq 0 
        end
      end

      context "on create" do 
        it 'raises errors when did and depositor are not specified' do 
          params = {}
          validator = CoreFileValidator.new(params)
          validator.create_or_update = :create
          validator.validate_required_attributes
          expect(validator.errors.length).to eq 2 
        end

        it 'raises no error when did and depositor are specified' do 
          params = { :tei => "12", :depositor => "432" }
          validator = CoreFileValidator.new(params)
          validator.create_or_update = :create 
          validator.validate_required_attributes
          expect(validator.errors.length).to eq 0
        end
      end
    end
  end
end
