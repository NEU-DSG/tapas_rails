require 'spec_helper'

describe Exist::ValidateTei do 
  include FileHelpers

  it 'returns some errors when the mods is invalid' do 
    expect(Exist::ValidateTei.execute(fixture_file('xml.xml'))).not_to be_empty
  end

  it 'raises no errors when the mods is not invalid' do 
    expect(Exist::ValidateTei.execute(fixture_file('tei.xml'))).to be_empty
  end

  pending 'write better tests once eXist gives back better output'
end
