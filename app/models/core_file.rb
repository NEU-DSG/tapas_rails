class CoreFile < CerberusCore::BaseModels::CoreFile
  include Did
  include OGReference
  include DrupalAccess

  parent_collection_relationship :collection 

  # Add definitions for all ographies
  has_and_belongs_to_many :xography_for, :property => :is_xography_for, 
    :class_name => "Collection"
  has_and_belongs_to_many :personography_for, :property => :is_personography_for,
    :class_name => "Collection"
  has_and_belongs_to_many :orgography_for, :property => :is_orgography_for,
    :class_name => "Collection"
  has_and_belongs_to_many :bibliography_for, :property => :is_bibliography_for,
    :class_name => "Collection"
  has_and_belongs_to_many :otherography_for, :property => :is_otherography_for,
    :class_name => "Collection"
  has_and_belongs_to_many :odd_file_for, :property => :is_odd_file_for,
    :class_name => "Collection"

  has_metadata :name => "mods", :type => ModsDatastream
  has_metadata :name => "properties", :type => PropertiesDatastream
end
