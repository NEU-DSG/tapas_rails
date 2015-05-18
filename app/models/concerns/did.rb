module Did
  extend ActiveSupport::Concern 

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

    has_attributes :did, datastream: "mods", multiple: false 
  end
end
