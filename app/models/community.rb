class Community < CerberusCore::BaseModels::Community
  include Nid

  has_collection_types ["Collection"]
  has_community_types  ["Community"]
  has_core_file_types  ["CoreFile"]

  parent_community_relationship :community 

  # Override default properties ds with our custom one.
  has_metadata :name => "properties", :type => PropertiesDatastream
end
