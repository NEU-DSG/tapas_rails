# This module implements queries that are both TAPAS specific and worth having 
# on both the SolrDocument/Fedora Object models of a record.
module TapasQueries
  extend ActiveSupport::Concern
  included do 
    def teibp(as = :models)
      teibp = self.content_objects(:raw).find do |x| 
        x["active_fedora_model_ssi"] == "HTMLFile" && 
          x["html_type_ssi"] == "teibp"
      end

      load_specified_type(teibp, as)
    end

    def tapas_generic(as = :models)
      tg = self.content_objects(:raw).find do |x| 
        x["active_fedora_model_ssi"] == "HTMLFile" && 
          x["html_type_ssi"] == "tapas_generic"
      end

      load_specified_type(tg, as)
    end

    private 

    def load_specified_type(solr_response, type) 
      return nil unless solr_response

      models = %i(models base_model base_models model)
      docs = %i(solr_documents solr_document solr_doc solr_docs)
      raw = %i(raw raws solr_response solr_responses)

      if models.include? type 
        klass = solr_response["active_fedora_model_ssi"].constantize
        return klass.find(solr_response["id"])
      elsif docs.include? type 
        return SolrDocument.new solr_response
      elsif raw.include? type 
        return solr_response
      end
    end
  end
end
