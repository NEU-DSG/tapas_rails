require 'spec_helper' 

describe 'TapasQueries' do 

  describe '#all_ography_tei_files' do 

    after(:all) { ActiveFedora::Base.delete_all }

    def create_ography(collection, ography_assignment) 
      core_file = FactoryGirl.create :core_file 
      core_file.collections << collection 
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
    it "can retrieve all ography tei files associated with a Collection" do 
      collection = FactoryGirl.create :collection 

      otherography = create_ography(collection, :otherography_for=)
      personography = create_ography(collection, :personography_for=)
      orgography = create_ography(collection, :orgography_for=)
      bibliography = create_ography(collection, :bibliography_for=)
      odd_file = create_ography(collection, :odd_file_for=)      

      collection.reload 

      expected_pids = [otherography.pid, personography.pid, orgography.pid,
       bibliography.pid, odd_file.pid] 

      # Assert that this works for Collection objects
      result = collection.all_ography_tei_files(:solr_docs) 
      result.map! { |x| x.pid }
      expect(result).to match_array expected_pids

      # Assert that this works for SolrDocument objects
      solr_doc = SolrDocument.new collection.to_solr 
      result = solr_doc.all_ography_tei_files(:solr_docs) 
      result.map! { |x| x.pid } 
      expect(result).to match_array expected_pids
    end
  end
end
