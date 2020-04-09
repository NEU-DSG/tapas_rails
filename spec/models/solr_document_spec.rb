require 'spec_helper'

describe SolrDocument do
  describe '#any_public_collections?' do

    it 'returns false when called on non-CoreFiles' do
      doc = SolrDocument.new FactoryBot.create(:collection).to_solr

      expect(doc.any_public_collections?).to be false
    end

    it 'returns false for CoreFiles with no collections' do
      doc = SolrDocument.new FactoryBot.create(:core_file).to_solr

      expect(doc.any_public_collections?).to be false
    end

    it 'returns false for CoreFiles with all private collections' do
      cf = FactoryBot.create :core_file
      coll1, coll2 = FactoryBot.create_list(:collection, 2)

      coll1.drupal_access = 'private' ; coll1.save!
      coll2.drupal_access = 'private' ; coll2.save!

      cf.collections = [coll1, coll2] ; cf.save!

      doc = SolrDocument.new cf.to_solr

      expect(doc.any_public_collections?).to be false
    end

    it 'returns true for CoreFiles with a public collection' do
      cf = FactoryBot.create :core_file
      coll1, coll2 = FactoryBot.create_list(:collection, 2)

      coll1.drupal_access = 'private' ; coll1.save!
      coll2.drupal_access = 'public' ; coll2.save!

      cf.collections = [coll1, coll2] ; cf.save!

      doc = SolrDocument.new cf.to_solr

      expect(doc.any_public_collections?).to be true
    end
  end
end
