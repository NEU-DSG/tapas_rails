require 'spec_helper'

describe Collection do
  include FileHelpers

  describe 'Core File access' do
    let(:coll) { FactoryBot.create(:collection) }

    context 'on a collection that has been made public' do
      it 'is set to public' do
        one, two = FactoryBot.create_list(:core_file, 2)

        one.update(is_public: false, collections: [coll])
        two.update(is_public: false, collections: [coll])

        expect(one.reload.is_public).to be_falsy
        expect(two.reload.is_public).to be_falsy

        coll.update(is_public: true)

        expect(one.reload.is_public).to be_truthy
        expect(two.reload.is_public).to be_truthy
      end
    end

    context 'on a collection that has been made private' do
      it 'is set to private unless the object has other public collections' do
        one, two = FactoryBot.create_list(:core_file, 2)

        coll.update(is_public: true)

        public_collection = FactoryBot.create(:collection, is_public: true)
        private_collection = FactoryBot.create(:collection)

        one.update(collections: [coll, public_collection], is_public: true)
        two.update(collections: [coll, private_collection], is_public: true)

        coll.reload.update(is_public: false)

        expect(one.reload.is_public).to be_truthy
        expect(two.reload.is_public).to be_falsy
      end
    end
  end

  it_behaves_like 'InlineThumbnails'
end
