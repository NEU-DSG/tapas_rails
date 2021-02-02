require 'spec_helper'
require "cancan/matchers"

describe User do
  let(:institution) { FactoryBot.create :institution }
  let(:user) { FactoryBot.create(:user, institution: institution) }
  let(:community) { FactoryBot.create(:community, depositor: user, institutions: [institution]) }

  describe '#communities' do
    it 'has many communities' do
      expect(user.communities).to include(community)
    end

    context 'permissions' do
      subject(:ability) { Ability.new(user) }
      let(:non_admin_community) { FactoryBot.create(:community) }
      let(:private_community) { FactoryBot.create(:community, is_public: false) }

      it { is_expected.to be_able_to(:update, community) }
      it { is_expected.not_to be_able_to(:update, non_admin_community) }
      it { is_expected.to be_able_to(:destroy, community) }
      it { is_expected.not_to be_able_to(:destroy, non_admin_community) }
      it { is_expected.to be_able_to(:read, non_admin_community) }
      it { is_expected.not_to be_able_to(:read, private_community) }

      describe 'collections' do
        let(:collection) { FactoryBot.create(:collection, depositor: user, community: community) }
        let(:public_collection) { FactoryBot.create(:collection, is_public: true) }
        let(:private_collection) { FactoryBot.create(:collection, is_public: false) }

        it { is_expected.to be_able_to(:update, collection) }
        it { is_expected.not_to be_able_to(:update, public_collection) }
        it { is_expected.to be_able_to(:destroy, collection) }
        it { is_expected.not_to be_able_to(:destroy, public_collection) }
        it { is_expected.to be_able_to(:read, public_collection) }
        it { is_expected.not_to be_able_to(:read, private_collection) }

        describe 'core_files' do
          let(:core_file) { FactoryBot.create(:core_file, collections: [collection], depositor: user) }
          let(:public_core_file) { FactoryBot.create(:core_file, collections: [public_collection], is_public: true) }
          let(:private_core_file) { FactoryBot.create(:core_file, collections: [private_collection], is_public: false) }

          it { is_expected.to be_able_to(:update, core_file) }
          it { is_expected.not_to be_able_to(:update, public_core_file) }
          it { is_expected.to be_able_to(:destroy, core_file) }
          it { is_expected.not_to be_able_to(:destroy, public_core_file) }
          it { is_expected.to be_able_to(:read, public_core_file) }
          it { is_expected.not_to be_able_to(:read, private_core_file) }
        end
      end
    end
  end
end
