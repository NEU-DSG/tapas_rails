namespace :solr_cleanup do
  desc "delete all indexed solr data"
  task :delete => :environment do
    SolrHelpers.delete_all_indexed_records

    puts "\nAll solr data removed from index." if SolrHelpers.record_count == 0
  end
end
