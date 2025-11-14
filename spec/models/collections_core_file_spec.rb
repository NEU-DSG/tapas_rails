require 'spec_helper'

describe CollectionsCoreFile do
  describe 'multi-project prevention validation' do
    let(:user) { FactoryBot.create(:user) }
    let(:project1) { FactoryBot.create(:project, depositor: user) }
    let(:project2) { FactoryBot.create(:project, depositor: user) }
    let(:collection1) { FactoryBot.create(:collection, project: project1, depositor: user) }
    let(:collection2) { FactoryBot.create(:collection, project: project2, depositor: user) }
    let(:core_file) { FactoryBot.create(:core_file, depositor: user) }

    context 'when adding to first collection' do
      it 'allows the association' do
        association = CollectionsCoreFile.new(collection: collection1, core_file: core_file)
        expect(association.valid?).to be true
      end
    end

    context 'when adding to multiple collections in same project' do
      it 'allows the association' do
        collection1_2 = FactoryBot.create(:collection, project: project1, depositor: user)

        CollectionsCoreFile.create!(collection: collection1, core_file: core_file)
        association2 = CollectionsCoreFile.new(collection: collection1_2, core_file: core_file)

        expect(association2.valid?).to be true
      end
    end

    context 'when adding to collection in different project' do
      it 'prevents the association' do
        CollectionsCoreFile.create!(collection: collection1, core_file: core_file)
        association2 = CollectionsCoreFile.new(collection: collection2, core_file: core_file)

        expect(association2.valid?).to be false
        expect(association2.errors[:base].join).to match(/Core file cannot belong to collections from multiple projects/)
      end

      it 'raises validation error when using shovel operator' do
        core_file.collections << collection1

        expect {
          core_file.collections << collection2
        }.to raise_error(ActiveRecord::RecordInvalid, /Core file cannot belong to collections from multiple projects/)
      end
    end
  end
end
