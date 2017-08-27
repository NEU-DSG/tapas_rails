class Community < CerberusCore::BaseModels::Community
  include Did
  include OGReference
  include DrupalAccess
  include TapasQueries
  include InlineThumbnail
  include StatusTracking
  include SolrHelpers
  include TapasRails::MetadataAssignment

  before_save :ensure_unique_did
  before_save :match_dc_to_mods
  after_save :update_permissions
  after_create :set_depositor_as_admin

  has_collection_types ["Collection"]
  has_community_types  ["Community"]

  parent_community_relationship :community

  has_metadata :name => "mods", :type => ModsDatastream
  has_metadata :name => "properties", :type => PropertiesDatastream

  has_attributes :project_members, datastream: "properties", multiple: true
  has_attributes :project_editors, datastream: "properties", multiple: true
  has_attributes :project_admins, datastream: "properties", multiple: true
  has_attributes :og_reference, datastream:"properties"
  has_attributes :title, datastream: "DC"
  has_attributes :description, datastream: "DC"

  validates_presence_of :title

 # Look up or create the root community of the graph
  def self.root_community
    if Community.exists?(Rails.configuration.tap_root)
      Community.find(Rails.configuration.tap_root)
    else
      community = Community.new(:pid => Rails.configuration.tap_root, :title => "Root community")
      community.depositor = "000000000"
      community.mass_permissions = "private"
      community.save!
      return community
    end
  end

  def as_json
    fname = (thumbnail_1.label == 'File Datastream' ? '' : thumbnail_1.label)
    { :members => project_members,
      :admins => project_admins,
      :editors => project_editors,
      :depositor => depositor,
      :access => drupal_access,
      :thumbnail => fname,
      :title => mods.title.first,
      :description => mods.abstract.first
    }
  end

  def match_dc_to_mods
    # self.DC.title = self.mods.title.first
    # self.DC.description = self.mods.abstract.first if !self.mods.abstract.blank?
    self.mods.title = self.DC.title.first
    self.mods.abstract = self.DC.description.first
  end

  def to_solr(solr_doc = Hash.new())
    solr_doc["active_fedora_model_ssi"] = self.class
    solr_doc["type_sim"] = "Project"
    super(solr_doc)
    return solr_doc
  end

  def update_permissions
    if !self.properties.project_members.blank?
      self.properties.project_members.each do |p|
        self.rightsMetadata.permissions({person: p}, 'read')
      end
    end
    if !self.properties.project_admins.blank?
      self.properties.project_admins.each do |p|
        self.rightsMetadata.permissions({person: p}, 'edit')
      end
    end
    if !self.properties.project_editors.blank?
      self.properties.project_editors.each do |p|
        self.rightsMetadata.permissions({person: p}, 'edit')
      end
    end
    self.save!
  end

  def set_depositor_as_admin
    self.properties.project_admins = [self.depositor]
    self.rightsMetadata.permissions({person: self.depositor}, 'edit')
    self.save!
  end
end
