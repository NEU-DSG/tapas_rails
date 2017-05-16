module SolrHelpers
  extend ActiveSupport::Concern

  def index_record
    ActiveFedora::SolrService.instance.conn.add(self.to_solr)
    ActiveFedora::SolrService.instance.conn.commit
  end

  def remove_from_index
    ActiveFedora::SolrService.instance.conn.delete(self.id)
    ActiveFedora::SolrService.instance.conn.commit
  end
end
