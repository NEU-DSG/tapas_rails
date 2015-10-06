module Did
  extend ActiveSupport::Concern 
  def ensure_unique_did 
    if self.did.present? && self.pid.present?
      did = RSolr.solr_escape self.did
      pid = RSolr.solr_escape self.pid  

      query = "did_ssim:#{did} && -id:#{pid}"

      if ActiveFedora::SolrService.query(query).any?
        msg = "Attempted to reuse Drupal ID #{did}" 
        raise Exceptions::DuplicateDidError.new msg
      end
    end
  end

  def exists_by_did?(nid)
    return ActiveFedora::Base.exists?("did_ssim" => nid) 
  end

  module_function :exists_by_did?

  included do 
    # Use solr to look up an object with a given content type 
    # by drupal node reference id.
    def self.find_by_did(did)
      return self.where("did_ssim" => did).first
    end

    def self.exists_by_did?(did)
      return self.exists?('did_ssim' => did)
    end

    has_attributes :did, datastream: "mods", multiple: false 
  end
end
