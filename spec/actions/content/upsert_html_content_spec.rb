require "spec_helper" 

describe UpsertHTMLContent do 
  include FileHelpers
  describe "#upsert!" do 
    let(:core_file) { FactoryGirl.create(:core_file) } 
    let(:u) { UpsertHTMLContent }

    it "raises an error and deletes the file when given invalid HTML" do 
      fpath = copy_fixture("image.jpg", "#{SecureRandom.hex}.jpg")
      error = Exceptions::InvalidZipError

      expect { u.upsert!(core_file, fpath, :teibp) }.to raise_error error
      expect(File.exists? fpath).to be false
    end

    it "raises an error and deletes the file when given an invalid file_type" do
      fpath = copy_fixture("image.jpg", "#{SecureRandom.hex}.jpg")
      error = StandardError 

      expect { u.upsert!(core_file, fpath, :william) }.to raise_error error
      expect(File.exists? fpath).to be false
    end

    context "when creating a teibp html file" do 
      let(:teibp) { @core_file.teibp }
      
      after(:all) { ActiveFedora::Base.delete_all }

      before(:all) do 
        @file = copy_fixture("teibp.html", "#{SecureRandom.hex}.html")
        @filename = Pathname.new(@file).basename.to_s
        @core_file = FactoryGirl.create(:core_file)
        UpsertHTMLContent.upsert!(@core_file, @file, :teibp)
      end

      it "builds the expected HTMLFile object" do 
        expect(teibp).to be_an_instance_of HTMLFile
      end

      it "cleans up the file" do 
        expect(File.exists? @file).to be false
      end

      it "writes the file to the content datastream" do 
        expected_content = File.read(fixture_file("teibp.html"))
        expect(teibp.content.content).to eq expected_content
        expect(teibp.content.label).to eq @filename
      end
    end

    context "when creating a tapas_generic html file" do 
      let(:tapas_generic) { @core_file.tapas_generic } 

      after(:all) { ActiveFedora::Base.delete_all }

      before(:all) do 
        @file = copy_fixture("tapas_generic.html", "#{SecureRandom.hex}.html")
        @filename = Pathname.new(@file).basename.to_s
        @core_file = FactoryGirl.create(:core_file) 
        UpsertHTMLContent.upsert!(@core_file, @file, :tapas_generic)
      end

      it "builds the expected HTMLFile object" do 
        expect(@core_file.tapas_generic).to be_an_instance_of HTMLFile
      end

      it "cleans up the file" do 
        expect(File.exists? @file).to be false
      end

      it "writes the file to the content datastream" do 
        expected_content = File.read(fixture_file("tapas_generic.html"))
        expect(tapas_generic.content.content).to eq expected_content 
        expect(tapas_generic.content.label).to eq @filename
      end
    end
  end
end
