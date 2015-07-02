class Community < CerberusCore::BaseModels::Community
  include Did
  include OGReference
  include DrupalAccess
  include TapasQueries

  has_collection_types ["Collection"]
  has_community_types  ["Community"]
  has_core_file_types  ["CoreFile"]

  parent_community_relationship :community 

  has_metadata :name => "mods", :type => ModsDatastream
  has_metadata :name => "properties", :type => PropertiesDatastream

  has_attributes :project_members, datastream: "properties", multiple: true

  has_many :personographies, :property => :is_personography_for, 
    :class_name => "CoreFile"
  has_many :orgographies, :property => :is_orgography_for, 
    :class_name => "CoreFile"
  has_many :bibliographies, :property => :is_bibliography_for, 
    :class_name => "CoreFile"
  has_many :otherographies, :property => :is_otherography_for, 
    :class_name => "CoreFile"
  has_many :odd_files, :property => :is_odd_file_for, 
    :class_name => "CoreFile"

  # Look up or create the root community of the graph
  def self.root_community
    if Community.exists?(Rails.configuration.tap_root)
      Community.find(Rails.configuration.tap_root)
    else
      community = Community.new(:pid => Rails.configuration.tap_root)
      community.depositor = "000000000"
      community.mods.title = "TAPAS root"
      community.mass_permissions = "private" 
      community.save!
      return community
    end
  end
end
