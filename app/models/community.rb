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

  # TODO: (charles) Unclear whether a collection can be shared among multiple communities.
  # What's the best way to find out?
  # has_many :community_collections
  has_many :collections #, through: :community_collections
  has_many :children, through: :community_collections, source: :collection
  has_many :community_members
  has_many :users, through: :community_members
  has_and_belongs_to_many :communities,
                          join_table: "community_communities",
                          association_foreign_key: "parent_community_id"

  has_many :communities_institutions
  has_many :institutions, through: :communities_institutions

  belongs_to :depositor, class_name: "User"

  has_many_attached :thumbnails

  validates_presence_of :title

  # Look up or create the root community of the graph
  # FIXME: (charles) I'm not sure why communities are related in a graph here -- is this used anywhere, or can we drop it?
  # def self.root_community
  #   if Community.exists?(Rails.configuration.tap_root)
  #     Community.find(Rails.configuration.tap_root)
  #   else
  #     community = Community.new(:pid => Rails.configuration.tap_root, :title => "Root community")
  #     community.depositor = "000000000"
  #     community.mass_permissions = "private"
  #     community.save!
  #     return community
  #   end
  # end

  def create_members(user_ids = [], member_type = 'member')
    # NOTE: (charles) This means that the order in which CommunityMembers are created matters: the last
    # (community_id, user_id, member_type) will prevail for that community_id + user_id. In other words,
    # selecting the same user in multiple roles is undefined behavior.

    user_ids.reject(&:empty?).each do |uid|
      CommunityMember.find_or_create_by(community_id: id, user_id: uid, member_type: member_type)
    end
  end

  def institutions=(institution_ids)
    puts "creating institutions"
    institution_ids.reject(&:empty?).each do |iid|
      CommunitiesInstitution.find_or_create_by(community_id: id, institution_id: iid)
    end
  end

  def project_members=(user_ids)
    create_members(user_ids)
  end

  def project_members
    users
  end

  def project_editors=(user_ids)
    create_members(user_ids, 'editor')
  end

  def project_editors
    users.where(community_members: { member_type: ["editor", "admin"] })
  end

  def project_admins=(user_ids)
    create_members(user_ids, 'admin')
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
      :access => drupal_access,
      :thumbnail => fname,
      :title => mods.title.first,
      :description => mods.abstract.first
    }
  end

  def can_read?(user)
    community_members.where(user_id: user.id).any?
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

  def clean_edit_users
    return self.edit_users.keep_if{ |k| k != "" }
  end

end
