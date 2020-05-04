require 'spec_helper'

describe RebuildReadingInterfaceJob do
  include FileHelpers
  include FixtureBuilders

  after(:each) { ActiveFedora::Base.delete_all }

  let(:core) { FactoryBot.create :core_file }
  let(:tei) { FactoryBot.create :tei_file }

  it 'rebuilds the reading interface when given a valid CoreFile' do
    skip("Test passes locally but not on Travis.") if ENV['TRAVIS']
    FactoryBot.create :tapas_generic
    FactoryBot.create :teibp
    cf, cl, p = FixtureBuilders.create_all
    tei.core_file = cf
    tei.canonize
    tei.content.content = File.read(fixture_file('tei.xml'))
    tei.save! ; cf.reload

    cf.mark_upload_failed!

    RebuildReadingInterfaceJob.perform(cf.did)

    cf.reload

    expect(cf.upload_complete?).to be true
    expect(cf.teibp).not_to be nil
    expect(cf.tapas_generic).not_to be nil
  end
end
