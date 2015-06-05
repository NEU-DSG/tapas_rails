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

  RSpec.shared_examples "a TEI validating operation" do |method| 
    it "that rejects files that aren't valid TEI" do 
      p = fixture_file "xml.xml" 
      expect { zcv.send(method, p) }.to raise_error Exceptions::InvalidZipError
    end

    it "that accepts files that are valid TEI" do 
      p = fixture_file "tei.xml" 
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

  describe ".tei" do 
    it_should_behave_like "an xml validating operation", :tei
    it_should_behave_like "a TEI validating operation", :tei
  end

  describe ".tfc" do 
    it_should_behave_like "an xml validating operation", :tfc
    it_should_behave_like "a TEI validating operation", :tfc
  end

  describe ".html" do 
    it "raises an error if the file doesn't have an .html extension" do
      p = fixture_file "image.jpg" 
      expect { zcv.html(p) }.to raise_error Exceptions::InvalidZipError
    end
  end

  describe ".support_files" do 
    it "raises an error if a support file isn't a jpg or png" do 
      sfs = [fixture_file("image.jpg"), fixture_file("mods.xml")]
      expect { zcv.support_files(sfs) }.to raise_error Exceptions::InvalidZipError
    end
  end
end
