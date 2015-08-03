require "spec_helper" 

describe ExtractFiles do 
  include FileHelpers

  describe "#execute" do 
    context "with all supported file types" do 
      before(:all) do 
        @response = ExtractFiles.execute(fixture_file("all_files.zip"))
      end

      after(:all) do 
        FileUtils.rm_r("#{Rails.root}/tmp/extracted_files")
      end  

      it "creates multiple files holding support image content" do 
        @response[:support_files].each do |sf| 
          expect(File.exists?(sf)).to be true 
        end 
      end

      it 'creates a file holding thumbnail content' do 
        thumbnail = @response[:thumbnail]

        expect(thumbnail).not_to be nil 
        expect(File.exists? thumbnail).to be true

        filename = Pathname.new(thumbnail).basename.to_s
        expect(filename).to eq 'thumbnail.jpg'
      end

      it "stores the directory that the files were written to" do 
        expect(@response[:directory]).to include "#{Rails.root}/tmp/extracted_files"
        expect(@response[:thumbnail]).to include @response[:directory]
      end
    end
  end
end
