class CoreFile < CerberusCore::BaseModels::CoreFile
  include Nid
  parent_collection_relationship :collection 

  # Override default properties ds with our custom one.
  has_metadata :name => "mods", :type => ModsDatastream
end
