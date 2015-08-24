require 'spec_helper'

describe CoreFileValidator do 
  include ValidatorHelpers
  include FileHelpers


  describe '#validate_file_type' do 
    let(:base_params) do
      { :tei => 'file.xml', :depositor => 'test' }
    end

    def validate_file_types(params, create_or_update)
      validator = CoreFileValidator.new params 
      validator.create_or_update = create_or_update 
      validator.validate_file_type
      validator
    end

    it 'raises an error when an invalid file type is passed' do 
      params = base_params.merge(:file_types => ['notography', 'personography'])
      validator = validate_file_types(params, :create)
      expect(validator.errors.length).to eq 1 
      
      error_msg = 'Invalid ography types were specified'
      expect(validator.errors.first).to eq error_msg
    end

    it 'raises no error if no file types are passed' do 
      validator = validate_file_types(base_params, :create) 
      expect(validator.errors.length).to eq 0 
    end

    it 'casts strings to single item arrays' do 
      params = base_params.merge(:file_types => 'odd_file')
      validator = validate_file_types(params, :create) 
      expect(validator.errors.length).to eq 0 
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
      let(:params) do 
        {:tei => Rack::Test::UploadedFile.new(fixture_file('image.jpg')),
         :collection_dids => ['1', '2', '3'], 
         :depositor => SecureRandom.uuid }
      end

      def it_raises_one_error_without(param)
        validator = CoreFileValidator.new(params.except(param))
        validator.create_or_update = :create 
        validator.validate_required_attributes
        expect(validator.errors.length).to eq 1
      end

      it 'raises an error when no depositor is specified' do 
        it_raises_one_error_without :depositor
      end

      it 'raises an error when no collection_dids are present' do 
        it_raises_one_error_without :collection_dids
      end

      it 'raises an error when no tei is present' do 
        it_raises_one_error_without :tei
      end

      it 'raises no error when collection_dids and depositor are specified' do 
        validator = CoreFileValidator.new(params)
        validator.create_or_update = :create 
        validator.validate_required_attributes
        expect(validator.errors.length).to eq 0
      end
    end
  end
end
