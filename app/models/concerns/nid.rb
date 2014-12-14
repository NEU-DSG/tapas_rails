module Nid 
  extend ActiveSupport::Concern 

  included do 
    # Use solr to look up an object with a given content type 
    # by drupal node reference id.
    def self.find_by_nid(nid)
      return self.where("nid_ssim" => nid).first
    end

    # Access fedora directly and check if an object with a particular 
    # nid already exists.
    def self.exists_by_nid?(nid)
      ActiveFedora::Base.exists?("nid_ssim" => nid)
    end

    has_attributes :nid, datastream: "mods", multiple: false 
  end
end
