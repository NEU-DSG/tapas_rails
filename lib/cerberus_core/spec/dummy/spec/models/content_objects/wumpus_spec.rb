require 'spec_helper'

describe Wumpus do 

  describe "ownership" do 
    before(:all) do
     @core = CoreFile.new 
     @core.depositor = "Will" 
     @core.save! 
   end

    let(:wumpus) { Wumpus.new } 
    after(:each) { wumpus.destroy if wumpus.persisted? } 

    it "defaults to no core file" do 
      expect(wumpus.core_file).to be nil 
    end

    it "can be assigned" do 
      wumpus.core_file = @core

      expect(wumpus.core_file).to eq @core 
    end

    after(:all) { @core.destroy }
  end

  describe "characterization" do 
    let(:wumpus) { Wumpus.new } 

    after(:each) { wumpus.destroy if wumpus.persisted? } 

    it "updates the characterization ds" do 
      pth  = Rails.root.join("spec", "fixtures", "files", "xml.xml") 
      file = File.open(pth).read 

      wumpus.add_file(file, "content", "xml.xml")

      expect(wumpus.characterization.content).to be nil

      wumpus.characterize

      expect(wumpus.characterization.content).to_not be nil
    end 
  end

  describe "content datastream" do 
    let(:wumpus) { Wumpus.new } 

    after(:each) { wumpus.destroy if wumpus.persisted? } 

    it "can have files added to it via #add_file method" do 
      pth = Rails.root.join("spec", "fixtures", "files", "xml.xml")
      file = File.open(pth).read

      wumpus.add_file(file, "content", "xml.xml") 
      wumpus.save!

      expect(wumpus.content.label).to eq("xml.xml") 
      expect(wumpus.content.content).to eq(file) 
    end
  end

  describe "type label" do 
    let(:wumpus) { Wumpus.new } 

    after(:each) { wumpus.destroy if wumpus.persisted? } 

    it "is a string describing the type of this content" do 
      expect(wumpus.type_label).to eq "Wumpus"
    end
  end

  it_behaves_like "A Properties Delegator"
end