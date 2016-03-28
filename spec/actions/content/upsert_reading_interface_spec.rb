require 'spec_helper'

describe Content::UpsertReadingInterface do
  include FileHelpers

  let(:core_file) { FactoryGirl.create :core_file }

  it 'raises an error when given invalid TEI' do
    file = fixture_file('xml.xml')
    action = Content::UpsertReadingInterface
    error = Exceptions::InvalidZipError
    expect { action.execute_all(core_file, file) }.to raise_error error
  end

  describe '.execute_all' do
    before(:all) do
      @core_file = FactoryGirl.create :core_file
      @core_file.collections = FactoryGirl.create_list(:collection, 2)
      @core_file.save!

      @tei = fixture_file 'tei.xml'

      Content::UpsertReadingInterface.execute_all @core_file, @tei
    end

    it 'does not delete the file at the given filepath' do
      expect(File.exists? @tei).to be true
    end

    it 'attaches a teibp html document with content to the CoreFile' do
      teibp = nil
      @core_file.html_files.each do |h|
        if h.html_type == "teibp"
          teibp = h
        end
      end
      expect(teibp).to be_instance_of HTMLFile
      expect(teibp.content.label).to eq 'teibp.xhtml'
      expect(teibp.content.content).to be_present
    end

    it 'attaches a tapas_generic html document with content to the CoreFile' do
      tapas_generic = nil
      @core_file.html_files.each do |h|
        if h.html_type == "tapas_generic"
          tapas_generic = h
        end
      end
      expect(tapas_generic).to be_instance_of HTMLFile
      expect(tapas_generic.content.label).to eq 'tapas-generic.xhtml'
      expect(tapas_generic.content.content).to be_present
    end
  end
end
