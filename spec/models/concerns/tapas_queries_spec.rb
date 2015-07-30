require 'spec_helper' 

describe 'TapasQueries' do 

  describe '#all_ography_tei_files' do 

    after(:all) { ActiveFedora::Base.delete_all }

    def create_ography(collection, ography_assignment) 
      core_file = FactoryGirl.create(:core_file)
      core_file.send(ography_assignment, [collection])
      core_file.save! 

      tei = TEIFile.create(:depositor => 'system') 
      tei.canonize
      tei.add_file('<xml>a</xml>', 'content', 'xml.xml')
      tei.core_file = core_file
      tei.save!
      tei
    end

    # This is sort of a monster of a single spec item but I'm not sure how 
    # to fix it or if it matters.
    it "can retrieve all ography tei files associated with a CoreFile's"\
       " Collections." do
      collection1 = FactoryGirl.create :collection
      collection2 = FactoryGirl.create :collection 
      collection3 = FactoryGirl.create :collection

      otherography = create_ography(collection1, :otherography_for=)
      personography = create_ography(collection2, :personography_for=)
      orgography = create_ography(collection3, :orgography_for=)
      bibliography = create_ography(collection1, :bibliography_for=)
      odd_file = create_ography(collection2, :odd_file_for=)      

      core_file = FactoryGirl.create :core_file
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
end
