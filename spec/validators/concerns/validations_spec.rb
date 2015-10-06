require 'spec_helper'

# Test class that implements a single field requiring each of the
# validations defined in the validations concern.
class TestObjectValidator
  include Validations

  def validate_upsert
    validate_all_present_params
    errors 
  end

  def validate_string
    validate_nonblank_string :string
  end

  def validate_string_array
    validate_array_of_strings :string_array
  end

  def validate_access
    validate_access_level
  end

  def validate_file
    validate_file_and_type(:file, %w(tei xml))
  end
end

describe Validations do 
  include FileHelpers

  let(:params) do 
    { :string => "A nonblank string", 
      :string_array => %w(an array of strings),
      :access => 'public',
      :file => Rack::Test::UploadedFile.new(
        fixture_file('tei.xml'), 'application/xml'
      ) }
  end

  def validate(params)
    ::TestObjectValidator.validate_upsert(params)
  end

  it 'raises no errors when all fields are valid' do 
    expect(validate(params).length).to eq 0 
  end

  it 'raises an error when an array of strings is not an array' do 
    errors = validate(params.merge(string_array: 'string_one'))
    expect(errors.length).to eq 1 
    expect(errors.first).to include 'string_array expects an array'
  end

  it 'raises an error when an array of strings contains nonstrings' do 
    errors = validate(params.merge(string_array: ['string', ['string_two']]))
    expect(errors.length).to eq 1
    expect(errors.first).to include 'contained blank or non-string values' 
  end

  it 'raises an error when a string is blank' do 
    errors = validate(params.merge(string: '     '))
    expect(errors.length).to eq 1 
    expect(errors.first).to include 'must be nonblank string'
  end

  it 'raises an error when a string is not a string' do 
    errors = validate(params.merge(string: %w(array of strings)))
    expect(errors.length).to eq 1 
    expect(errors.first).to include 'must be nonblank string'
  end

  it 'raises an error when access is not "public" or "private"' do 
    errors = validate(params.merge(access: 'secret'))
    expect(errors.length).to eq 1
    expect(errors.first).to include 'access must be one of: ' 
  end

  it 'raises an error when a file is not a file' do 
    errors = validate(params.merge(file: 'path/to/file'))
    expect(errors.length).to eq 1 
    expect(errors.first).to include 'must be a file upload' 
  end

  it 'raises an error when a file has an invalid extension' do 
    errors = validate(params.merge(file: Rack::Test::UploadedFile.new(
      fixture_file('image.jpg'), 'image/jpeg')))

    expect(errors.length).to eq 1 
    expect(errors.first).to include 'must be file with extension' 
  end
end

