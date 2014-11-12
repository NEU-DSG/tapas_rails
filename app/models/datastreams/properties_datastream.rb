class PropertiesDatastream < CerberusCore::Datastreams::PropertiesDatastream 
  use_terminology CerberusCore::Datastreams::PropertiesDatastream 

  extend_terminology do |t| 
    t.nid(index_as: :symbol)
  end

  def to_solr(solr_doc = {})
    solr_doc = super solr_doc

    solr_doc["drupal_nid_ssim"] = self.nid.first if self.nid.first.present?

    return solr_doc
  end

end
