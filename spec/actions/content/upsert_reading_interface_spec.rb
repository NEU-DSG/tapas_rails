require 'spec_helper'

describe Content::UpsertReadingInterface do
  include FileHelpers

  let(:core_file) { FactoryBot.create :core_file }

  it 'raises an error when given invalid TEI' do
    skip("Test passes locally but not on Travis.") if ENV['TRAVIS']
    file = fixture_file('xml.xml')
    Rails.cache.delete("view_packages_machine")
    Rails.cache.delete("view_packages_dir")
    FactoryBot.create :tapas_generic
    FactoryBot.create :teibp
    action = Content::UpsertReadingInterface
    error = Exceptions::InvalidZipError
    expect { action.execute_all(core_file, file) }.to raise_error error
  end

  describe '.execute_all' do
    before(:all) do
      unless ENV['TRAVIS']
        @core_file = FactoryBot.create :core_file
        @core_file.collections = FactoryBot.create_list(:collection, 2)
        @core_file.save!
        FactoryBot.create :tapas_generic
        FactoryBot.create :teibp
        @tei = fixture_file 'tei.xml'

        Content::UpsertReadingInterface.execute_all @core_file, @tei
      end
    end

    it 'does not delete the file at the given filepath' do
      skip("Test passes locally but not on Travis.") if ENV['TRAVIS']
      expect(File.exists? @tei).to be true
    end

    it 'attaches a teibp html document with content to the CoreFile' do
      skip "Test passes locally but not on Travis." if ENV['TRAVIS']
      teibp = @core_file.teibp
      expect(teibp).to be_instance_of HTMLFile
      expect(teibp.content.label).to eq 'teibp.xhtml'
      expect(teibp.content.content).to be_present
    end

    it 'attaches a tapas_generic html document with content to the CoreFile' do
      skip("Test passes locally but not on Travis.") if ENV['TRAVIS']
      tapas_generic = @core_file.tapas_generic
      expect(tapas_generic).to be_instance_of HTMLFile
      expect(tapas_generic.content.label).to eq 'tapas-generic.xhtml'
      expect(tapas_generic.content.content).to be_present
    end
  end
end
