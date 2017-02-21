require 'spec_helper'

describe Exist::ValidateTei do
  include FileHelpers

  it 'returns some errors when the file is invalid xml' do
    skip("Test passes locally but not on Travis.") if ENV['TRAVIS']
    errors = Exist::ValidateTei.execute(fixture_file('xml.xml'))
    expect(errors.length).to eq 3
  end

  it 'raises an error when the file is not xml' do
    skip("Test passes locally but not on Travis.") if ENV['TRAVIS']
    expect { Exist::ValidateTei.execute(fixture_file('image.jpg')) }
    .to raise_error RestClient::BadRequest
  end

  it 'raises no errors when the tei is not invalid' do
    skip("Test passes locally but not on Travis.") if ENV['TRAVIS']
    expect(Exist::ValidateTei.execute(fixture_file('tei.xml'))).to be_empty
  end
end
