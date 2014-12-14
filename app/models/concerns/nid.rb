module Nid 
  extend ActiveSupport::Concern 

  def exists_by_nid?(nid)
    return ActiveFedora::Base.exists?("nid_ssim" => nid) 
  end

  module_function :exists_by_nid?

  included do 
    # Use solr to look up an object with a given content type 
    # by drupal node reference id.
    def self.find_by_nid(nid)
      return self.where("nid_ssim" => nid).first
    end

    has_attributes :nid, datastream: "mods", multiple: false 
  end
end
