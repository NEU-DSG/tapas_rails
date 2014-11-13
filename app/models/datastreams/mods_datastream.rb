class ModsDatastream < CerberusCore::Datastreams::ModsDatastream 
  use_terminology CerberusCore::Datastreams::ModsDatastream 

  extend_terminology do |t| 
    t.nid(path: "identifier", namespace_prefix: "mods", attributes: { type: "tapas_id" })
  end

  def to_solr(solr_doc = {})
    solr_doc = super solr_doc 

    solr_doc["tapas_nid_ssim"] = self.nid.first if self.nid.first.present?

    return solr_doc
  end
end
