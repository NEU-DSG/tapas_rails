require 'spec_helper' 

describe Content::UpsertTei do
  include FileHelpers

  it "raises an error and deletes the file when passed invalid TEI" do 
    file = copy_fixture("xml.xml", "#{SecureRandom.hex}.xml")
    core_file = FactoryGirl.create(:core_file) 

    e = Exceptions::InvalidZipError
    expect { Content::UpsertTei.execute(core_file, file) }.to raise_error e
    expect(File.exists? file).to be false
  end


  context 'when updating a TEI file' do 
    let(:tei) { @core_file.canonical_object }

    before(:all) do 
      @file = copy_fixture('tei.xml', "#{SecureRandom.uuid}.xml")
      @filename = Pathname.new(@file).basename.to_s
      @core_file = FactoryGirl.create :core_file 
      @tei_file = FactoryGirl.create :tei_file 
      @tei_file.add_file('<xml>xml</xml>', 'content', 'previous.xml')
      @tei_file.core_file = @core_file
      @tei_file.canonize
      @tei_file.save!
      Content::UpsertTei.execute(@core_file, @file)
    end

    it 'does not create another TEIFile object' do 
      expect(@core_file.content_objects(:raw).count).to eq 1 
      expect(@core_file.content_objects(:models).first).to eq @tei_file
    end

    it 'versions the added content datastream' do 
      expect(tei.content.versions.count).to eq 2 
      expect(tei.content.label).to eq @filename 
      expect(tei.content.versions.last.label).to eq 'previous.xml'
    end

    it 'deletes the file after insertion into the repository' do 
      expect(File.exists? @file).to be false
    end
  end

  context "when creating a TEI file" do 
    let(:tei) { @core_file.canonical_object }

    before(:all) do 
      @file = copy_fixture("tei.xml", "#{SecureRandom.hex}.xml") 
      @filename = Pathname.new(@file).basename.to_s 
      @core_file = FactoryGirl.create(:core_file) 
      Content::UpsertTei.execute(@core_file, @file)
    end

    after(:all) { @core_file.destroy }

    it "creates the expected TEIFile object" do 
      expect(tei).to be_an_instance_of TEIFile 
    end

    it "writes content to the object" do 
      expect(tei.content.content).to eq File.read(fixture_file 'tei.xml')
    end

    it "cleans up the file" do 
      expect(File.exists? @filename).to be false
    end
  end
end
