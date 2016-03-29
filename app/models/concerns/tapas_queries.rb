# This module implements queries that are both TAPAS specific and worth having
# on both the SolrDocument/Fedora Object models of a record.
module TapasQueries
  extend ActiveSupport::Concern

  # def teibp(as = :models)
  #   teibp = self.content_objects(:raw).find do |x|
  #     x["active_fedora_model_ssi"] == "HTMLFile" &&
  #       x["html_type_ssi"] == "teibp"
  #   end
  #
  #   load_specified_type(teibp, as)
  # end
  #
  # def tapas_generic(as = :models)
  #   tg = self.content_objects(:raw).find do |x|
  #     x["active_fedora_model_ssi"] == "HTMLFile" &&
  #       x["html_type_ssi"] == "tapas_generic"
  #   end
  #
  #   load_specified_type(tg, as)
  # end
  #
  # def thumbnail(as = :models)
  #   thumb = self.content_objects(:raw).find do |x|
  #     x['active_fedora_model_ssi'] == 'ImageThumbnailFile'
  #   end
  #
  #   load_specified_type(thumb, as)
  # end

  # Returns all of the TEIFile objects that are declared as ographies
  # for Collections to which this CoreFile belongs
  def all_ography_tei_files
    pid = get_pid
    unless expected_class? CoreFile
      raise "all_ographies expects a CoreFile Object."
    end

    if self.is_a? ActiveFedora::Base
      collections = self.collections.map { |c| "info:fedora/#{c.pid}" }
    elsif self.is_a?(SolrDocument) || self.is_a?(Hash)
      collections = self['is_member_of_ssim']
    end

    return [] if collections.blank?

    collections.map! { |x| RSolr.solr_escape x }
    collections = "(#{collections.join(' OR ')})"

    all_verbs = ["is_personography_for_ssim:#{collections}",
      "is_orgography_for_ssim:#{collections}",
      "is_bibliography_for_ssim:#{collections}",
      "is_otherography_for_ssim:#{collections}",
      "is_odd_file_for_ssim:#{collections}",
      "is_placeography_for_ssim:#{collections}",]

      all_verbs = all_verbs.join(" OR ")
      all_core_files = ActiveFedora::SolrService.query(all_verbs)

      new_query = all_core_files.map do |core_file|
        id = RSolr.solr_escape("info:fedora/#{core_file['id']}")
        "(canonical_tesim:yes AND is_tfc_for_ssim:#{id})"
      end

      tei_files = ActiveFedora::SolrService.query(new_query.join(' OR '))
      tei_files.map { |x| TEIFile.find("#{x['id']}") }
  end

  private

  def expected_class?(class_constant)
    matches_class = false

    if self.is_a? ActiveFedora::Base
      return self.instance_of? class_constant
    elsif self.is_a? SolrDocument
      return (self.klass == class_constant.to_s)
    elsif self.is_a? Hash
      return (self['active_fedora_model_ssi'] == class_constant.to_s)
    else
      raise QueryObjectError.new "Passed a TapasQuery a #{self.class}.  "\
        "Must use an ActiveFedora model, a SolrDocument, or a to_solr Hash."
    end
  end


  def get_pid
    if self.is_a? ActiveFedora::Base
      pid = self.pid
    elsif self.is_a?(SolrDocument) || self.is_a?(Hash)
      pid = self[:id] || self['id']
    else
      raise QueryObjectError.new "Passed a TapasQuery a #{self.class}.  "\
        "Must use an ActiveFedora model, a SolrDocument, or a to_solr Hash."
    end

    pid
  end

  # def load_specified_type(solr_response, type)
  #   return nil unless solr_response
  #
  #   models = %i(models base_model base_models model)
  #   docs = %i(solr_documents solr_document solr_doc solr_docs)
  #   raw = %i(raw raws solr_response solr_responses)
  #
  #   if models.include? type
  #     klass = solr_response["active_fedora_model_ssi"].constantize
  #     return klass.find(solr_response["id"])
  #   elsif docs.include? type
  #     return SolrDocument.new solr_response
  #   elsif raw.include? type
  #     return solr_response
  #   end
  # end
end
