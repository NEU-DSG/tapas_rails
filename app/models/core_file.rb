class CoreFile < CerberusCore::BaseModels::CoreFile
  include Nid
  parent_collection_relationship :collection 

  has_metadata :name => "mods", :type => ModsDatastream
end
