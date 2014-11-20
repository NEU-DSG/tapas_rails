class CoreFile < CerberusCore::BaseModels::CoreFile
  include Nid
  include OGReference

  parent_collection_relationship :collection 

  has_metadata :name => "mods", :type => ModsDatastream
  has_metadata :name => "properties", :type => PropertiesDatastream
end
