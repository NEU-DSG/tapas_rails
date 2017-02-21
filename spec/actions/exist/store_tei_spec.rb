require 'spec_helper'

describe Exist::StoreTei do
  include FileHelpers
  include FixtureBuilders

  after(:all) { ActiveFedora::Base.delete_all }

  it 'returns a 201 for valid uploads' do
    skip("Test passes locally but not on Travis.") if ENV['TRAVIS']
    file = fixture_file 'tei.xml'
    core_file, collections, community = FixtureBuilders.create_all

    response = Exist::StoreTei.execute(file, core_file)
    expect(response.code).to eq 201
  end
end
