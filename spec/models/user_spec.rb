require 'spec_helper'

describe User do
  let(:institution) { FactoryBot.create :instutition }
  let(:user) { FactoryBot.create(:user, institution: institution)  }

  describe "#communities" do
    let(:community) { FactoryBot.create(:community, depositor: user, institutions: [institution])}

    it "has many communities" do
      skip
    end
  end
end
