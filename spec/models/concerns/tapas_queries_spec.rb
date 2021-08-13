require 'spec_helper'

describe 'TapasQueries' do
  let(:core_file) { FactoryBot.create(:core_file) }
  let(:collection) { FactoryBot.create(:collection) }
  let(:community) { FactoryBot.create(:community) }

  describe '#all_ography_tei_files' do

    after(:all) { ActiveFedora::Base.delete_all }

    def create_ography(collection, ography_assignment)
      core_file = FactoryBot.create(:core_file)
      core_file.send(ography_assignment, [collection])
      core_file.save!

      tei = TEIFile.create(:depositor => 'system')
      tei.canonize
      tei.add_file('<xml>a</xml>', 'content', 'xml.xml')
      tei.core_file = core_file
      tei.save!
      tei
    end

    it "can retrieve all ography tei files associated with a CoreFile's"\
      " Collections." do
      collection1 = FactoryBot.create :collection
      collection2 = FactoryBot.create :collection
      collection3 = FactoryBot.create :collection

      otherography = create_ography(collection1, :otherography_for=)
      personography = create_ography(collection2, :personography_for=)
      orgography = create_ography(collection3, :orgography_for=)
      bibliography = create_ography(collection1, :bibliography_for=)
      odd_file = create_ography(collection2, :odd_file_for=)

      core_file.collections = [collection1, collection2, collection3]
      core_file.save!

      expected_pids = [otherography.pid, personography.pid, orgography.pid,
        bibliography.pid, odd_file.pid]

      # Assert that this works for CoreFile objects
      result = core_file.all_ography_tei_files(:solr_docs)
      result.map! { |x| x.pid }
      expect(result).to match_array expected_pids

      # Assert that this works for SolrDocument objects
      solr_doc = SolrDocument.new core_file.to_solr
      result = solr_doc.all_ography_tei_files(:solr_docs)
      result.map! { |x| x.pid }
      expect(result).to match_array expected_pids
      end
  end

  describe '#thumbnail' do
    let(:thumbnail_file) { FactoryBot.create :image_thumbnail_file }

    it 'returns nil for Communities' do
      expect(community.thumbnail).to be nil
    end

    it 'returns nil for Collections' do
      expect(collection.thumbnail).to be nil
    end

    it 'returns nil for CoreFiles with no thumbnail' do
      expect(core_file.thumbnail).to be nil
    end

    it 'returns the ThumbnailFile object for CoreFiles that have one' do
      thumbnail_file.core_file = core_file
      thumbnail_file.save!

      thumb_doc = SolrDocument.new(thumbnail_file.to_solr)

      model = core_file
      doc   = SolrDocument.new(model.to_solr)

      expect(model.thumbnail).to eq thumbnail_file
      expect(doc.thumbnail).to eq thumbnail_file

      expect(model.thumbnail(:solr_doc).pid).to eq thumb_doc.pid
    end
  end
end
