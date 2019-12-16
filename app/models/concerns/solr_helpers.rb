module SolrHelpers
  extend ActiveSupport::Concern

  def index_record
    ActiveFedora::SolrService.instance.conn.add(self.to_solr)
    ActiveFedora::SolrService.instance.conn.commit
  end

  def remove_from_index
    id = defined? self.pid ? self.pid : self.id
    ActiveFedora::SolrService.instance.conn.delete_by_id("#{id}")
    ActiveFedora::SolrService.instance.conn.commit
  end
end
