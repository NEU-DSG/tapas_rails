class Community < ActiveRecord::Base
  # include Did
  # include OGReference
  # include DrupalAccess
  # include TapasQueries
  # include InlineThumbnail
  # include StatusTracking
  # include SolrHelpers
  # include TapasRails::MetadataAssignment

  # before_save :ensure_unique_did
  # before_save :match_dc_to_mods
  # before_save :update_permissions
  # after_create :set_depositor_as_admin

  # has_collection_types ["Collection"]
  # has_community_types  ["Community"]

  # parent_community_relationship :community

  # has_metadata :name => "mods", :type => ModsDatastream
  # has_metadata :name => "properties", :type => PropertiesDatastream

  # has_attributes :project_members, datastream: "properties", multiple: true
  # has_attributes :project_editors, datastream: "properties", multiple: true
  # has_attributes :project_admins, datastream: "properties", multiple: true
  # has_attributes :institutions, datastream: "properties", multiple: true
  # has_attributes :og_reference, datastream:"properties"
  # has_attributes :title, datastream: "DC"
  # has_attributes :description, datastream: "DC"

  has_many :community_collections
  has_many :collections, through: :community_collections, source: :collection
  has_many :community_members
  has_many :members, through: :community_members, source: :user
  has_and_belongs_to_many :communities, join_table: "community_communities", association_foreign_key: "parent_community_id"
  has_many :thumbnails, as: :owner

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

  def project_members
    members
  end

  def project_editors
    members.where(member_type: ["editor", "admin"])
  end

  def project_admins
    members.where(member_type: "admin")
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
    if !self.properties.project_members.blank? && self.mass_permissions != "public"
      self.properties.project_members.each do |p|
        if !p.blank?
          self.rightsMetadata.permissions({person: p}, 'read')
        end
      end
    end
    if self.mass_permissions == "public"
      self.read_users.each do |p|
        # if its public don't put the project_members as read users
        self.rightsMetadata.permissions({person: p}, 'none')
      end
    end
    if !self.properties.project_admins.blank?
      self.properties.project_admins.each do |p|
        if !p.blank?
          self.rightsMetadata.permissions({person: p}, 'edit')
        end
      end
    end
    if !self.properties.project_editors.blank?
      self.properties.project_editors.each do |p|
        if !p.blank?
          self.rightsMetadata.permissions({person: p}, 'edit')
        end
      end
    end
    # if diff between project_admins + project_editors and edit_users then remove the diff
    edits = (self.properties.project_admins + self.properties.project_editors).uniq
    diff = self.clean_edit_users - edits
    logger.info(diff)
    diff.each do |d|
      if !d.blank?
        self.rightsMetadata.permissions({person: d}, 'none')
      end
    end
    # TODO - do i need to propagate permissions to the collection at this time?
    if self.collections
      self.collections.each do |col|
        if col && Collection.exists?(col.id)
          col.save!
        end
      end
    end
  end

  def set_depositor_as_admin
    self.properties.project_admins = [self.depositor]
    self.rightsMetadata.permissions({person: self.depositor}, 'edit')
    # self.save!
  end

  def remove_thumbnail
    self.thumbnail_list = []
    self.save!
  end

  def member_objects
    member_objects = {}
    if !self.project_admins.blank?
      member_objects[:admins] = []
      self.project_admins.each do |pa|
        if User.exists?(pa)
          member_objects[:admins] << User.find(pa)
        end
      end
    end
    if !self.project_editors.blank?
      member_objects[:editors] = []
      self.project_editors.each do |pe|
        if User.exists?(pe)
          member_objects[:editors] << User.find(pe)
        end
      end
    end
    if !self.project_members.blank?
      member_objects[:members] = []
      self.project_members.each do |pm|
        if User.exists?(pm)
          member_objects[:members] << User.find(pm)
        end
      end
    end
    return member_objects
  end

  def members_with_roles
    members_with_roles = []
    if !self.project_admins.blank?
      self.project_admins.each do |pa|
        if User.exists?(pa)
          members_with_roles << {user:User.find(pa), roles:["admin"]}
        end
      end
    end
    if !self.project_editors.blank?
      self.project_editors.each do |pe|
        if User.exists?(pe)
          user = User.find(pe)
          if not self.project_admins.include?(pe)
            members_with_roles << {user:user, roles:["editor"]}
          end
        end
      end
    end
    if !self.project_members.blank?
      self.project_members.each do |pm|
        if User.exists?(pm)
          user = User.find(pm)
          if (not self.project_admins.include?(pm)) && (not self.project_editors.include?(pm))
            members_with_roles << {user:user, roles:["member"]}
          end
        end
      end
    end
    return members_with_roles
  end

  def clean_edit_users
    return self.edit_users.keep_if{ |k| k != "" }
  end

end
