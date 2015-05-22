require 'spec_helper'

describe ModsDatastream do 
  let(:mods) { ModsDatastream.new }

  describe "Identifier disambiguation" do 
    before(:each) do 
      mods.did = "did:1"
      mods.identifier = "pid:2"
    end

    it "doesn't return untyped ids when the did is requested" do 
      expect(mods.did).to eq ["did:1"]
    end

    it "doesn't return dids when the untyped id is requested" do 
      expect(mods.identifier).to eq ["pid:2"]
    end
  end
end
