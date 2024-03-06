# -*- encoding : utf-8 -*-
class SolrDocument
  # include Rails.application.routes.url_helpers
  include Blacklight::Solr::Document
  # include Blacklight::Gallery::OpenseadragonSolrDocument

  # include Blacklight::Document
  # include CerberusCore::SolrDocumentBehavior
  include TapasRails::SolrDocumentBehavior
  include TapasQueries

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension( Blacklight::Document::Email )

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension( Blacklight::Document::Sms )

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  # use_extension( Blacklight::Document::DublinCore)
  use_extension( Blacklight::Solr::Document::Mods )

  def any_public_collections?
   return false unless klass == 'CoreFile'

     pids = self['is_member_of_ssim']

     return false if pids.nil?

     # If pids is a string, this object only has a single collection
     # relationship.  However, to simplify the code, make it an array
     # before proceeding.
     pids = [pids] if pids.instance_of? String
     pids = pids.map { |x| "id:#{RSolr.solr_escape(x[12..-1])}" }
     query = pids.join ' OR '

     SolrService.query(query).any? do |collection|
       collection['drupal_access_ssim'] == ['public']
     end
  end
end
