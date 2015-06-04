require 'spec_helper' 

describe ZipContentValidator do 
  include FileHelpers

  let(:zcv) { ZipContentValidator }

  RSpec.shared_examples "an xml validating operation" do |method|
    it "that rejects files that aren't xml" do 
      p = fixture_file "image.jpg" 
      expect { zcv.send(method, p) }.to raise_error Exceptions::InvalidZipError
    end

    it "that rejects files that are badly formed xml" do 
      p = fixture_file "xml_malformed.xml" 
      expect { zcv.send(method, p) }.to raise_error Exceptions::InvalidZipError
    end
  end

  describe ".mods" do 
    it_should_behave_like "an xml validating operation", :mods

    it "rejects files that are invalid MODS" do 
      p = fixture_file "mods_invalid.xml"
      expect { zcv.mods p }.to raise_error Exceptions::InvalidZipError
    end
  end

  describe ".validate_tei" do 
    it_should_behave_like "an xml validating operation", :tei
  end

  describe ".validate_tfc" do 
    it_should_behave_like "an xml validating operation", :tfc
  end

  describe ".validate_support_files" do 
    it "raises an error if a support file isn't a jpg or png" do 
      sfs = [fixture_file("image.jpg"), fixture_file("mods.xml")]
      expect { zcv.support_files(sfs) }.to raise_error Exceptions::InvalidZipError
    end
  end
end
