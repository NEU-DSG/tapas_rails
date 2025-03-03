require 'spec_helper'

describe User do
  let(:institution) { FactoryBot.create :instutition }
  let(:user) { FactoryBot.create(:user, institution: institution)  }

  describe "#projects" do
    let(:project) { FactoryBot.create(:project, depositor: user, institutions: [institution])}

    it "has many projects" do
      skip
    end
  end
end
