class ModsDatastream < CerberusCore::Datastreams::ModsDatastream
  use_terminology CerberusCore::Datastreams::ModsDatastream

  extend_terminology do |t|
    t.identifier(path: "identifier", namespace_prefix: "mods", attributes: { type: :none })
    t.did(path: "identifier", namespace_prefix: "mods", attributes: { type: "did" })
  end

  def to_solr(solr_doc = {})
    solr_doc = super solr_doc

    solr_doc["did_ssim"] = self.did.first if self.did.first.present?
    solr_doc["abstract_tesim"] = self.abstract.first
    #solr_doc["thumbnail"] = self.thumbnail.first

    return solr_doc
  end
end
