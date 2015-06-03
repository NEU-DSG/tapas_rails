require 'spec_helper' 

describe TEIFile do 
  describe "TFC relationship" do 
    after(:each) { ActiveFedora::Base.delete_all } 

    it "is manipulated as an array" do 
      core = FactoryGirl.create(:core_file) 
      tei  = TEIFile.create(:depositor => "will") 

      tei.tfc_for << core ; tei.save!

      expect(tei.tfc_for).to match_array [core]
    end
  end
end
