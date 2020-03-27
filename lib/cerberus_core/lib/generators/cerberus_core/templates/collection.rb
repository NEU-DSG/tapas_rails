class Collection < CerberusCore::BaseModels::Collection
  has_core_file_types  ["CoreFile"]
  has_collection_types ["Collection"]

  parent_community_relationship  :community 
  parent_collection_relationship :collection
end