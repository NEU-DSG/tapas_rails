require 'spec_helper'

describe TapasXq::StoreMods do
  include FileHelpers
  include FixtureBuilders

  before(:all) do
    @core_file, @collections, @project = FixtureBuilders.create_all
  end

  after(:all) { ActiveFedora::Base.delete_all }

  it 'returns a 201 for valid storage requests' do
    skip("Test passes locally but not on Travis.") if ENV['TRAVIS']
    file = fixture_file 'tei.xml'
    TapasXq::StoreTei.execute(file, @core_file)

    response = TapasXq::StoreMods.execute(file, @core_file)
    expect(response.code).to eq 201
  end

  it 'passes optional params correctly' do
    skip("Test passes locally but not on Travis.") if ENV['TRAVIS']
    file = fixture_file 'tei.xml'
    TapasXq::StoreTei.execute(file, @core_file)

    opts = {
      :tei_authors => ['Bob Jenkins'],
      :tei_contributors => ['Cotton Mathers'],
      :date => Time.now.iso8601,
      :title => 'Test Store Mods Request'
    }

    response = TapasXq::StoreMods.execute(file, @core_file, opts)

    expect(response.code).to eq 201
    expect(response.include?(opts[:tei_authors].first)).to be true
    expect(response.include?(opts[:tei_contributors].first)).to be true
    expect(response.include?(opts[:date].first)).to be true
    expect(response.include?(opts[:title].first)).to be true
  end
end
