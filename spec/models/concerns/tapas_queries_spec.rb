require 'spec_helper' 

describe 'TapasQueries' do 

  describe '#all_ography_tei_files' do 

    after(:all) { ActiveFedora::Base.delete_all }

    def create_ography(community, ography_assignment) 
      core_file = FactoryGirl.create :core_file 
      core_file.send(ography_assignment, [community])
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
    it "can retrieve all ography tei files associated with a community" do 
      community = FactoryGirl.create :community 

      otherography = create_ography(community, :otherography_for=)
      personography = create_ography(community, :personography_for=)
      orgography = create_ography(community, :orgography_for=)
      bibliography = create_ography(community, :bibliography_for=)
      odd_file = create_ography(community, :odd_file_for=)      

      community.reload 

      expected_pids = [otherography.pid, personography.pid, orgography.pid,
       bibliography.pid, odd_file.pid] 

      # Assert that this works for community objects
      result = community.all_ography_tei_files(:solr_docs) 
      result.map! { |x| x.pid }
      expect(result).to match_array expected_pids

      # Assert that this works for SolrDocument objects
      solr_doc = SolrDocument.new community.to_solr 
      result = solr_doc.all_ography_tei_files(:solr_docs) 
      result.map! { |x| x.pid } 
      expect(result).to match_array expected_pids
    end
  end
end
