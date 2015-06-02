require "spec_helper" 

describe ExtractFiles do 
  include FileHelpers

  describe "#extract!" do 
    context "with all supported file types" do 
      before(:all) do 
        @response = ExtractFiles.extract!(fixture_file("all_files.zip"))
      end

      #Cleanup
      after(:all) do 
        FileUtils.rm_r("#{Rails.root}/tmp/extracted_files")
      end  

      it "creates a file holding mods content" do 
        expect(File.exists?(@response[:mods])).to be true 
        expect(File.size(@response[:mods])).not_to eq 0
      end

      it "creates a file holding tei content" do 
        expect(File.exists?(@response[:tei])).to be true 
      end

      it "creates a file holding tfc content" do 
        expect(File.exists?(@response[:tfc])).to be true 
      end

      it "creates multiple files holding support image content" do 
        @response[:support_files].each do |sf| 
          expect(File.exists?(sf)).to be true 
        end 
      end
    end
  end

  context "with no support files or mods record" do 
    before(:all) do 
      @response = ExtractFiles.extract!(fixture_file("tei_tfc_only.zip"))
    end

    after(:all) { FileUtils.rm_r "#{Rails.root}/tmp/extracted_files" }

    it "returns nil for the mods file" do 
      expect(@response[:mods]).to be nil 
    end

    it "returns nil for the support files array" do 
      expect(@response[:support_files]).to be nil 
    end

    it "returns a file holding tfc content" do 
      expect(File.exists?(@response[:tfc])).to be true 
    end

    it 'returns a file holding tei content' do 
      expect(File.exists?(@response[:tei])).to be true
    end
  end
end
