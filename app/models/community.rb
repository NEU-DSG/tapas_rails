class Community < CerberusCore::BaseModels::Community
  include Nid
  include OGReference
  include DrupalAccess

  has_collection_types ["Collection"]
  has_community_types  ["Community"]
  has_core_file_types  ["CoreFile"]

  parent_community_relationship :community 

  has_metadata :name => "mods", :type => ModsDatastream
  has_metadata :name => "properties", :type => PropertiesDatastream

  has_attributes :project_members, datastream: "properties", multiple: true

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
