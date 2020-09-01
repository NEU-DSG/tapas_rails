require 'spec_helper'

describe TEIFile do
  describe "TFC relationship" do

    it "is manipulated as an array" do
      core = FactoryBot.create(:core_file)
      tei  = TEIFile.create(:depositor => "will")

      tei.tfc_for << core ; tei.save!

      expect(tei.tfc_for).to match_array [core]
    end
  end

  it_behaves_like 'DownloadPath'
end
