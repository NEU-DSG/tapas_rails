# class ModsDatastream < CerberusCore::Datastreams::ModsDatastream
#   use_terminology CerberusCore::Datastreams::ModsDatastream
#
#   extend_terminology do |t|
#     t.identifier(path: "identifier", namespace_prefix: "mods", attributes: { type: :none })
#     t.did(path: "identifier", namespace_prefix: "mods", attributes: { type: "did" })
#     t.display_authors(path: "name", namespace_prefix: "mods", attributes: {displayLabel: "TAPAS Author"}){
#       t.name_part(path: "namePart", namespace_prefix: 'mods', index_as: [:stored_searchable, :facetable])
#       t.role(path: "role", namespace_prefix: 'mods')
#     }
#     t.display_contributors(path: "name", namespace_prefix: "mods", attributes: {displayLabel: "TAPAS Contributor"}){
#       t.name_part(path: "namePart", namespace_prefix: 'mods', index_as: [:stored_searchable, :facetable])
#       t.role(path: "role", namespace_prefix: 'mods')
#     }
#   end
#
#   def to_solr(solr_doc = {})
#     solr_doc = super solr_doc
#
#     solr_doc["did_ssim"] = self.did.first if self.did.first.present?
#     solr_doc["abstract_tesim"] = self.abstract.first
#     solr_doc["display_authors_ssim"] = self.display_authors.name_part
#     solr_doc["display_contributors_ssim"] = self.display_contributors.name_part
#     solr_doc["authors_tesim"] = self.authors
#     solr_doc["contributors_tesim"] = self.contributors
#     return solr_doc
#   end
#
#   def authors
#     return self.display_authors.name_part
#   end
#
#   def contributors
#     return self.display_contributors.name_part
#   end
# end
