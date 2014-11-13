class Collection < CerberusCore::BaseModels::Collection
  include Nid
  has_core_file_types  ["CoreFile"]
  has_collection_types ["Collection"]

  parent_community_relationship  :community 
  parent_collection_relationship :collection

  # Override default properties ds with our custom one.
  has_metadata :name => "properties", :type => PropertiesDatastream
end
