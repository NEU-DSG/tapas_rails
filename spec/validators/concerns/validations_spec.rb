require 'spec_helper'

# Test class that implements a single field requiring each of the
# validations defined in the validations concern.
class TestObjectValidator
  include Validations

  def validate_upsert
    validate_all_present_params
    errors
  end

  def validate_empty_string
    validate_string :empty_string
  end

  def validate_present_string
    validate_nonblank_string :present_string
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

describe TestObjectValidator do
  include FileHelpers
  include ValidatorHelpers

  let(:params) do
    { :empty_string => '',
      :present_string => "A nonblank string",
      :string_array => %w(an array of strings),
      :access => 'public',
      :file => Rack::Test::UploadedFile.new(
        fixture_file('tei.xml'), 'application/xml'
      ) }
  end

  it 'raises no errors when all fields are valid' do
    expect(validate(params).length).to eq 0
  end

  it 'raises no error the string array is empty' do
    expect(validate(params.merge(string_array: [])).length).to eq 0
  end

  it 'raises an error when an array of strings is not an array' do
    validate(params.merge(string_array: 'string_one'))
    it_raises_a_single_error 'string_array expects an array'
  end

  it 'raises an error when an array of strings contains nonstrings' do
    validate(params.merge(string_array: ['string', ['string_two']]))
    it_raises_a_single_error 'contained blank or non-string values'
  end

  it 'raises an error when a nonblank string is blank' do
    validate(params.merge(present_string: '     '))
    it_raises_a_single_error 'must be nonblank string'
  end

  it 'raises an error when a string is not a string' do
    validate(params.merge(present_string: %w(array of strings)))
    it_raises_a_single_error 'must be nonblank string'
  end

  it 'raises an error when access is not "public" or "private"' do
    validate(params.merge(access: 'secret'))
    it_raises_a_single_error 'access must be one of: '
  end

  it 'raises an error when a file is not a file' do
    validate(params.merge(file: 'path/to/file'))
    it_raises_a_single_error 'must be a file upload'
  end

  it 'raises an error when a file has an invalid extension' do
    validate(params.merge(file: Rack::Test::UploadedFile.new(
      fixture_file('image.jpg'), 'image/jpeg')))

    it_raises_a_single_error 'must be file with extension'
  end
end
