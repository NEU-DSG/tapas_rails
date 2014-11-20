module OGReference 
  extend ActiveSupport::Concern 

  # Return every object that references this object 
  # as its parent via drupal og nids.
  def self.find_all_in_og(og)
    results = ActiveFedora::SolrService.query("drupal_og_reference_ssim:\"#{og}\"")

    results.map { |result| SolrDocument.new(result) } 
  end
  
  included do 
    has_attributes :og_reference, datastream: "properties", multiple: false
    delegate :og_reference=, to: "properties"
  end
end
