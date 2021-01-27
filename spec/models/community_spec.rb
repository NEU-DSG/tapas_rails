require 'spec_helper'
require 'cancan/matchers'

describe Community do
  let(:institution) { FactoryBot.create(:institution) }
  let(:user) { FactoryBot.create(:user, institution: institution) }
  let(:community) do
    FactoryBot.create(:community,
                      depositor: user,
                      users: [user],
                      institutions: [institution])
  end

  it 'has many Users as members' do
    expect(community.users.count).to equal(1)
  end

  it 'has a depositor' do
    expect(community.depositor).to be(user)
  end

  describe '.create' do
    it 'sets the depositor as an admin' do
      c = Community.create!(title: 'Title', depositor: user, institutions: [institution])

      expect(c.reload.project_admins).to include(user)
    end
  end

  describe '#can_read?' do
    subject(:ability) { Ability.new(user) }

    context 'when user is a member' do
      it { is_expected.to be_able_to(:read, community) }
    end

    context 'when user is non-member' do
      let(:user) { FactoryBot.create(:user) }
      let(:private) { FactoryBot.create(:community, is_public: false) }

      it { is_expected.not_to be_able_to(:read, private) }
    end
  end

  it_behaves_like 'InlineThumbnails'
end
