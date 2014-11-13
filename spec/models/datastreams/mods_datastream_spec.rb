require 'spec_helper'

describe ModsDatastream do 
  let(:mods) { ModsDatastream.new }

  describe "Identifier disambiguation" do 
    before(:each) do 
      mods.nid        = "nid:1"
      mods.identifier = "pid:2"
    end

    it "doesn't return untyped ids when the nid is requested" do 
      expect(mods.nid).to eq ["nid:1"]
    end

    it "doesn't return nids when the untyped id is requested" do 
      expect(mods.identifier).to eq ["pid:2"]
    end
  end
end
