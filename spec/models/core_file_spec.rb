require 'spec_helper'

describe CoreFile do
  include FileHelpers
  include FixtureBuilders
  include TapasRails::ViewPackages

  let(:core_file) { FactoryBot.create :core_file }
  let(:collection) { FactoryBot.create :collection }
  let(:community) { FactoryBot.create :community }

  describe 'Collections relationship' do
    let(:core_file) { FactoryBot.create :core_file }

    it { respond_to :collections }
    it { respond_to :collections= }
    it { should_not respond_to :collection }
    it { should_not respond_to :collection= }

    it 'are manipulated as arrays' do
      c, d = FactoryBot.create_list(:collection, 2)

      core_file.collections << c
      core_file.collections << d

      expect(core_file.collections).to match_array [c, d]
    end
  end

  describe 'Users relationships' do
    let(:author) { FactoryBot.create :user }
    let(:contributor) { FactoryBot.create :user }
    let(:depositor) { FactoryBot.create :user }
    let(:file) { FactoryBot.create :core_file, depositor: depositor }


    it 'has authors and contributors' do
      file.authors << author
      file.contributors << contributor

      expect(file.authors).to match_array [author]
      expect(file.contributors).to match_array [contributor]
    end
  end

  describe '#project' do
    it 'returns nil for CoreFiles that belong to no collections' do
      expect(core_file.project).to be nil
    end

    it 'returns a project for CoreFiles that belong to an OK collection' do
      core_file.collections << collection
      core_file.save!

      collection.update(community: community)

      expect(core_file.project).to eq community
    end
  end

  describe 'view package methods' do
    it 'should have tapas_generic method when tapas_generic view package object exists' do
      FactoryBot.create :tapas_generic
      core_file.create_view_package_methods
      expect(core_file).to respond_to(:tapas_generic)
    end

    it "should not have method if the view_package doesn't exist" do
      FactoryBot.create :tapas_generic
      core_file.create_view_package_methods
      expect(core_file).to respond_to(:tapas_generic)
      CoreFile.remove_view_package_methods(['tapas_generic'])
      ViewPackage.all.each do |v|
        v.destroy
      end
      core_file.reload
      expect { core_file.tapas_generic }.to raise_error(NoMethodError)
    end
  end

  describe 'Ography relationships' do
    it { respond_to :personography_for }
    it { respond_to :personography_for= }
    it { respond_to :orgography_for }
    it { respond_to :bibliography_for }
    it { respond_to :bibliography_for= }
    it { respond_to :otherography_for }
    it { respond_to :otherography_for= }
    it { respond_to :odd_file_for }
    it { respond_to :odd_file_for= }
    it { respond_to :placeography_for }
    it { respond_to :placeography_for= }

    # ographies should just be collections, it seems?
  end

  describe 'Page Image relationships' do
    it { respond_to :page_images }
  end

  describe 'permissions' do
    it 'defaults to public' do
      expect(core_file.is_public).to be_truthy
    end

    it 'saves the object as public if it has a single public collection' do
      c1, c2, c3 = FactoryBot.create_list :collection, 3
      c1.update(is_public: false)
      c2.update(is_public: false)
      c3.update(is_public: true)

      core_file.update(collections: [c1, c2, c3])
      expect(core_file.is_public).to be_truthy
    end

    it 'saves the object as private if it has all private collections' do
      collections = FactoryBot.create_list :collection, 2
      collections.each do |collection|
        collection.update(is_public: false)
      end

      core_file.update(collections: collections)
      expect(core_file.reload.is_public).to be_falsy
    end
  end
end
