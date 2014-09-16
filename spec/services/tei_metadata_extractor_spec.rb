require 'spec_helper'

describe TEIMetadataExtractor do 

  describe "Metadata extraction" do

    context "With no available metadata" do 
      it "returns the title error" do 
        results = TEIMetadataExtractor.extract("<TEI>elem</TEI>")
        err = "Please give your TEI file a valid title and reupload the file."
        expect(results).to eq({title: err})
      end
    end

    context "With metadata" do 
      let(:extractor) do 
        path = Rails.root.join("spec", "fixtures", "files", "tei_with_metadata.xml")
        
      end

      it "Knows how to extract title elements" do 

      end
    end
  end
end
