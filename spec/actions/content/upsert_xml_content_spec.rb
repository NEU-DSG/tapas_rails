require 'spec_helper' 

describe UpsertXMLContent do 
  include FileHelpers

  describe "#upsert!" do 
    it "raises an error and deletes the file when passed an invalid xml_type" do 
      file = copy_fixture("tei.xml", "#{SecureRandom.hex}.xml")
      core_file = FactoryGirl.create(:core_file)

      expect { UpsertXMLContent.upsert!(core_file, file, :abcdef) }.
        to raise_error StandardError 
      expect(File.exists? file).to be false
    end


    it "raises an error and deletes the file when passed invalid TEI" do 
      file = copy_fixture("xml.xml", "#{SecureRandom.hex}.xml")
      core_file = FactoryGirl.create(:core_file) 

      expect { UpsertXMLContent.upsert!(core_file, file, :tei) }.
        to raise_error Exceptions::InvalidZipError
      expect(File.exists? file).to be false
    end

    context "when creating a TEI file" do 
      let(:tei) { @core_file.canonical_object }

      before(:all) do 
       @file = copy_fixture("tei.xml", "#{SecureRandom.hex}.xml") 
       @filename = Pathname.new(@file).basename.to_s 
       @core_file = FactoryGirl.create(:core_file) 
       UpsertXMLContent.upsert!(@core_file, @file, :tei)
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

    context "when updating a TFC file" do 
      let(:tfc) { @core_file.tfc.first }
      before(:all) do 
        @file = copy_fixture("tei.xml", "#{SecureRandom.hex}.xml")
        @filename = Pathname.new(@file).basename.to_s 
        @core_file = FactoryGirl.create(:core_file)

        @tfc_file = TEIFile.create
        @tfc_file.tfc_for << @core_file 
        @old_file = File.read(fixture_file('tei_full_metadata.xml'))
        @tfc_file.add_file(@old_file, 'content', 'tei_full_metadata.xml')
        @tfc_file.save!
        UpsertXMLContent.upsert!(@core_file, @file, :tfc)
      end

      it "updates the previous object" do 
        expect(@core_file.tfc.count).to eq 1 
      end

      it "updates the object's content and label" do 
        expect(tfc.content.versions.length).to eq 2 
        expect(tfc.content.content).to eq File.read(fixture_file('tei.xml'))
        expect(tfc.content.label).to eq @filename
      end

      it "doesn't update the content datastream when given identical data" do 
        file = copy_fixture("tei.xml", @filename)
        UpsertXMLContent.upsert!(@core_file, file, :tfc)

        expect(tfc.content.versions.length).to eq 2 
      end
    end
  end
end
