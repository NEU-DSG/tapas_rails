require "spec_helper" 

describe ExtractFiles do 
  include FileHelpers

  describe "#extract!" do 
    context "with all supported file types" do 
      before(:all) do 
        copy_fixture("all_files.zip", "all_files_copy.zip")
        @response = ExtractFiles.extract!(fixture_file("all_files_copy.zip"))
      end

      #Cleanup
      after(:all) do 
        FileUtils.rm_r("#{Rails.root}/tmp/extracted_files")
      end  

      it "creates a file holding teibp content" do 
        expect(File.exists?(@response[:teibp])).to be true 
        expect(File.size(@response[:teibp])).not_to eq 0 
      end

      it "creates a file holding tapas_generic content" do 
        expect(File.exists?(@response[:tapas_generic])).to be true 
        expect(File.size(@response[:tapas_generic])).not_to eq 0 
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

      it "removes the zipfile when it completes" do 
        expect(File.exists?("all_files_copy.zip")).to be false 
      end

      it "stores the directory that the files were written to" do 
        expect(@response[:directory]).to include "#{Rails.root}/tmp/extracted_files"
        expect(@response[:tei]).to include @response[:directory]
      end
    end

    context "with no support files or mods record" do 
      before(:all) do 
        copy_fixture("tei_tfc_only.zip", "tei_tfc_only_copy.zip")
        @response = ExtractFiles.extract!(fixture_file("tei_tfc_only_copy.zip"))
      end

      after(:all) { FileUtils.rm_r "#{Rails.root}/tmp/extracted_files" }

      it "returns nil for the mods file" do 
        expect(@response[:mods]).to be nil 
      end

      it "returns nil for the html file" do 
        expect(@response[:html]).to be nil 
      end

      it "returns an empty array for the support files array" do 
        expect(@response[:support_files]).to eq []
      end

      it "returns a file holding tfc content" do 
        expect(File.exists?(@response[:tfc])).to be true 
      end

      it 'returns a file holding tei content' do 
        expect(File.exists?(@response[:tei])).to be true
      end

      it "stores the directory that the files were written to" do 
        expect(@response[:directory]).to include "#{Rails.root}/tmp/extracted_files"
        expect(@response[:tei]).to include @response[:directory]
      end
    end
  end
end
