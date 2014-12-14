class ModsDatastream < CerberusCore::Datastreams::ModsDatastream 
  use_terminology CerberusCore::Datastreams::ModsDatastream 

  extend_terminology do |t| 
    t.identifier(path: "identifier", namespace_prefix: "mods", attributes: { type: :none })
    t.nid(path: "identifier", namespace_prefix: "mods", attributes: { type: "nid" })
  end

  def to_solr(solr_doc = {})
    solr_doc = super solr_doc 

    solr_doc["nid_ssim"] = self.nid.first if self.nid.first.present?

    return solr_doc
  end
end
