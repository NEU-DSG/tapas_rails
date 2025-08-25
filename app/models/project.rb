# frozen_string_literal: true

class Project < ApplicationRecord
  include Discard::Model
  include SolrHelpers

  validates_presence_of :title

  # associations
  belongs_to :depositor, class_name: "User"
  has_one_attached :image_file
  has_one :image_file, as: :imageable
  has_many :collections
  has_many :project_members
  has_many :users, through: :project_members
  has_and_belongs_to_many :core_files
  #TODO: create logic such that deleting a collection in a project, when the user has not specified the collection's core
  # files should be added to a new collection in that project, should delete the record associated with core file on the
  # project_core_files join table;

  # callbacks
  after_save :index_record
  after_update :update_record
  #TODO: add a callback to locate the indexed record by both active_record_model_ssi and id before deleting
  # before_destroy :remove_associations

  # TODO: create a migration to add contact_email and a contact_website columns for project; add free-text fields to haml view

  # 2025-05: Removed the methods below; the existing Project relationships should be enough.
  #def collections
    #Collection.all.where(project_id: id)
  #end
  
  # 2025-05: This method in particular added ~1 minute of page load to the browse projects page.
  #def core_files
    #CoreFile.all.select { |core_file| core_file.project == self }
  #end

  def project_group
    ProjectMember
      .all
      .where(project_id: id)
      .group_by(&:role)
  end

  def members
    user_members = {}

    project_group.each do |k, v|
      user_members[k] = v.map!(&:user)
    end

    user_members
  end

  def contributors
    members['contributor']
  end

  def collaborators
    members['collaborator']
  end

  def owner
    members['owner']
  end

  def to_solr(solr_doc = {})
    solr_doc["active_record_model_ssi"] = self.class.to_s
    solr_doc['depositor_tesim'] = depositor_id
    solr_doc['edit_access_person_ssim'] = members.empty? ? depositor_id : owner.id
    solr_doc['title_info_title_ssi'] = title
    solr_doc['table_id_ssi'] = id
    solr_doc['id'] = "#{self.class.to_s}_#{id}"
    solr_doc['access_ssim'] = is_public ? "public" : "private"
    solr_doc['thumbnail_list_tesim'] = 'public/assets/logo_no_text.png'
    # solr_doc['has_affiliation_ssim'] = # what are affiliations?

    solr_doc
  end

  def can_read?(user)
    can? :read
  end

  def remove_thumbnail
    self.thumbnails = []
    self.save!
  end

  def clean_edit_users
    return self.edit_users.keep_if{ |k| k != "" }
  end
end

#legacy code that needs review
# def as_json
#   fname = (thumbnail_1.label == 'File Datastream' ? '' : thumbnail_1.label)
#
#   { :members => project_members,
#     :admins => project_admins,
#     :editors => project_editors,
#     :depositor => depositor,
#     # :access => drupal_access,
#     :thumbnail => fname,
#     :title => mods.title.first,
#     :description => mods.abstract.first
#   }
# end

# def match_dc_to_mods
#   # self.DC.title = self.mods.title.first
#   # self.DC.description = self.mods.abstract.first if !self.mods.abstract.blank?
#   self.mods.title = self.DC.title.first
#   self.mods.abstract = self.DC.description.first
# end
# include OGReference
# include TapasQueries
# include InlineThumbnail
# include StatusTracking
# include Did
# include DrupalAccess
# include TapasRails::MetadataAssignment
# has_collection_types ["Collection"]
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
# has_one_attached :thumbnail

# Validations

# def member_objects
#   member_objects = {}
#   if !self.project_admins.blank?
#     member_objects[:admins] = []
#     self.project_admins.each do |pa|
#       if User.exists?(pa)
#         member_objects[:admins] << User.find(pa)
#       end
#     end
#   end
#   if !self.project_editors.blank?
#     member_objects[:editors] = []
#     self.project_editors.each do |pe|
#       if User.exists?(pe)
#         member_objects[:editors] << User.find(pe)
#       end
#     end
#   end
#   if !self.project_members.blank?
#     member_objects[:members] = []
#     self.project_members.each do |pm|
#       if User.exists?(pm)
#         member_objects[:members] << User.find(pm)
#       end
#     end
#   end
#   return member_objects
# end
#
# def members_with_roles
#   members_with_roles = []
#   if !self.project_admins.blank?
#     self.project_admins.each do |pa|
#       if User.exists?(pa)
#         members_with_roles << {user:User.find(pa), roles:["admin"]}
#       end
#     end
#   end
#   if !self.project_editors.blank?
#     self.project_editors.each do |pe|
#       if User.exists?(pe)
#         user = User.find(pe)
#         if not self.project_admins.include?(pe)
#           members_with_roles << {user:user, roles:["editor"]}
#         end
#       end
#     end
#   end
#   if !self.project_members.blank?
#     self.project_members.each do |pm|
#       if User.exists?(pm)
#         user = User.find(pm)
#         if (not self.project_admins.include?(pm)) && (not self.project_editors.include?(pm))
#           members_with_roles << {user:user, roles:["member"]}
#         end
#       end
#     end
#   end
#   return members_with_roles
# end


###  SCOPES  ###

public

# TODO: Figure out why `scope` is undefined
#scope :publicly_visible, -> { where(is_public: true) }
def publicly_visible
  where(is_public: true)
end

#scope :with_info_for_description, lambda {
#  select(:id, :title).includes(:collections, :core_files)
#}

