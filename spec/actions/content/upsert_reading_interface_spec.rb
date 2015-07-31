require 'spec_helper' 

describe Content::UpsertReadingInterface do 
  include FileHelpers

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
      teibp = @core_file.teibp
      expect(teibp).to be_instance_of HTMLFile 
      expect(teibp.content.label).to eq 'teibp.xhtml'
      expect(teibp.content.content).to be_present
    end

    it 'attaches a tapas_generic html document with content to the CoreFile' do
      tapas_generic = @core_file.tapas_generic
      expect(tapas_generic).to be_instance_of HTMLFile 
      expect(tapas_generic.content.label).to eq 'tapas-generic.xhtml'
      expect(tapas_generic.content.content).to be_present
    end
  end
end
