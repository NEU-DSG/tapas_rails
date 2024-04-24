class Community < ActiveRecord::Base
  include Discard::Model
  include SolrHelpers

  # include OGReference
  # include TapasQueries
  # include InlineThumbnail
  # include StatusTracking
  # include Did
  # include DrupalAccess
  # include TapasRails::MetadataAssignment
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
  # before_save :ensure_unique_did
  # after_create :set_depositor_as_admin
  # before_save :match_dc_to_mods
  # TODO: re-establish thumbnail functionality
  # has_one_attached :thumbnail

  # Validations
  validates_presence_of :title

  # Associations
  has_many :community_members
  has_many :members, through: :community_members, source: :user
  has_and_belongs_to_many :collections
  has_many :community_members
  has_many :users, through: :community_members

  has_and_belongs_to_many :communities,
                          join_table: "community_communities",
                          association_foreign_key: "parent_community_id"

  has_many :communities_institutions
  has_many :institutions, through: :communities_institutions

  belongs_to :depositor, class_name: "User"

  # Callbacks
  after_create :add_to_solr_index
  after_update :update_solr_index
  around_destroy :delete_from_solr_index
  #TODO: add this back from pre-archimedes tapas_rails
  # before_save :update_permissions


  def project_members
    users.where(community_members: { member_type: "member" })
  end

  def project_editors
    users.where(community_members: { member_type: "editor" })
  end

  def project_admins
    users.where(community_members: { member_type: "admin" })
  end

  def as_json
    fname = (thumbnail_1.label == 'File Datastream' ? '' : thumbnail_1.label)

    { :members => project_members,
      :admins => project_admins,
      :editors => project_editors,
      :depositor => depositor,
      # :access => drupal_access,
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

  def add_to_solr_index
    index_record if locate_record['numFound'] == 0
  end

  def update_solr_index
    update_record if locate_record['numFound'] > 0
  end

  def delete_from_solr_index
    delete_record if locate_record['numFound'] > 0
  end

  def to_solr(solr_doc = Hash.new())
    solr_doc["active_record_model_ssi"] = self.class.to_s
    solr_doc['depositor_tesim'] = depositor.id
    solr_doc['edit_access_person_ssim'] = project_admins.map(&:id)
    solr_doc['title_info_title_ssi'] = title
    solr_doc['table_id_ssi'] = id
    solr_doc['id'] = "#{self.class.to_s}_#{id}"
    solr_doc['access_ssim'] = is_public ? "public" : "private"
    solr_doc['thumbnail_list_tesim'] = 'public/assets/logo_no_text.png'
    # solr_doc['has_affiliation_ssim'] = #TODO: what are affiliations?

    solr_doc
  end

  def can_read?(user)
    can? :read
  end

  def remove_thumbnail
    self.thumbnails = []
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
