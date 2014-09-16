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

    # Test is a little squishy atm, not totally clear 
    # on what the specced behavior looks like 
    context "With metadata" do 
      before :all do 
        path = "#{Rails.root}/spec/fixtures/files/tei_full_metadata.xml"
        @extractor = TEIMetadataExtractor.new(File.read path) 
        @extractor.extract
      end

      it "grabs a title" do 
        expect(@extractor.response[:title]).to eq "After the Argument"
      end

      it "grabs a creator" do 
        expect(@extractor.response[:creator]).to eq "Walt Whitman"
      end

      it "grabs all contributors" do 
        expect(@extractor.response[:contributors].length).to eq 12
      end

      # The date in the sample TEI file we're using is defined as 
      # "sometime between 1890 and 1891"
      # Ought to check behavior with actual date
      it "returns a notification that the date was janky" do 
        expect(@extractor.response[:date]).to include "Could not parse date:"
      end

      it "grabs rights information" do 
        rights = "Copyright © 2001 by Ed Folsom and Kenneth M. Price, all " +
                 "rights reserved. Items in the Archive may be shared in " +
                 "accordance with the Fair Use provisions of U.S. copyright " + 
                 "law. Redistribution or republication on other terms, in " + 
                 "any medium, requires express written consent from the " + 
                 "editors and advance notification of the publisher, The " + 
                 "Institute for Advanced Technology in the Humanities. " + 
                 "Permission to reproduce the graphic images in this " + 
                 "archive has been granted by the owners of the originals " + 
                 "for this publication only."
        expect(@extractor.response[:rights]).to eq rights 
      end

      it "returns the document source" do 
        source_str = "Walt Whitman “After the Argument” 1890 or 1891 The " +
                     "Charles E. Feinberg Collection of the Papers of Walt " + 
                     "Whitman, Library of Congress, Washington, DC " + 
                     "Transcribed from Joel Myerson, ed. The Walt Whitman " + 
                     "Archive I: Whitman Manuscripts at the Library of " + 
                     "Congress, New York: Garland, 1993, Part I: 121; Major " + 
                     "American Authors on Cd-Rom: Walt Whitman, Westport, " +
                     "CT: Primary Source Media, 1997; our own digital image " +
                     "of original manuscript."

        expect(@extractor.response[:source]).to eq source_str 
      end
    end
  end
end
