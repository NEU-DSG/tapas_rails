class Collection < ActiveRecord::Base
  include Discard::Model

  # associations
  belongs_to :community
  belongs_to :depositor, class_name: "User", foreign_key: "depositor_id"
  has_and_belongs_to_many :core_files
  has_many_attached :thumbnails

  # validations
  validates :depositor_id, :description, :title, presence: true
  validates :community_id, presence: true, unless: :phantom?

  # callbacks
  after_create :set_collection_access

  def set_collection_access
    self.is_public = self.community.is_public
    self.save!
  end

  def self.phantom_collection
    pid = Rails.configuration.phantom_collection_pid
    if Collection.exists?(pid)
      return Collection.find(pid)
    else
      c = Collection.new(:pid => pid).tap do |c|
        c.title = "Orphaned TEI records."
        c.depositor = "tapasrails@neu.edu"
      end

      c.save!
      return c
    end
  end

  def as_json
    fname = (thumbnail_1.label == "File Datastream" ? '' : thumbnail_1.label)

    { :project_did => (community ? community.did : ''),
      :depositor => depositor,
      :title => mods.title.first,
      :access => drupal_access,
      :thumbnail => fname,
      :description => mods.abstract.first
    }
  end

  def community
    # from Solr drupal-core worksheet notes: "sm_field_tapas_project: string; For collections and core files, this is the machine-readable name of their containing project. In practice there is only ever one string in the array;"
    # also: "Drupal SQL table "og_membership", field "gid": The Drupal node ID of the project that the collection or core file belongs to."
   self.community_id.blank? ? nil : Community.find(self.community_id)
  end

  def depositor
    self.depositor_id.blank? ? nil : User.find(self.depositor_id)
  end

  def remove_thumbnail
    self.thumbnails = []
    self.save!
  end

  private

  def update_core_files
    return true unless @drupal_access_changed

    # If this collection is now private, we have to check to see if any other
    # collection that this object's CoreFiles belong to are public.  If none
    # are, we change that CoreFile to now also be private.
    if drupal_access == 'private'
      self.descendent_records(:solr_docs).each do |solr_doc|
        unless solr_doc.any_public_collections?
          puts "Private update being run"
          core_file = CoreFile.find(solr_doc.pid)
          core_file.drupal_access = 'private'
          core_file.save!
        end
      end
    # In this case we simply change all CoreFiles that this collection has
    # to be public, because a CoreFile has the least restrictive permission
    # level set by one of its parents
    elsif drupal_access == 'public'
      self.descendent_records(:raw).each do |record|
        unless record['drupal_access_ssim'] == 'public'
          core_file = CoreFile.find(record['id'])
          core_file.drupal_access = 'public'
          core_file.save!
        end
      end
    end
  end
end

# def update_permissions
#   # TO DO: verify what this actually does and where these updated permissions are stored;
#   if self.community
#     logger.info("updating permissions")
#     com_prop = self.community.properties
#     if !com_prop.project_members.blank? && (self.mass_permissions != "public" || self.project.mass_permissions != "public")
#       com_prop.project_members.each do |p|
#         self.rightsMetadata.permissions({person: p}, 'read')
#       end
#     end
#     if self.mass_permissions == "public" && self.project.mass_permissions == "public"
#       self.project.read_users.each do |p|
#         # if its public don't put the project_members as read users
#         self.rightsMetadata.permissions({person: p}, 'none')
#       end
#     end
#     if !com_prop.project_admins.blank?
#       com_prop.project_admins.each do |p|
#         self.rightsMetadata.permissions({person: p}, 'edit')
#       end
#     end
#     if !com_prop.project_editors.blank?
#       com_prop.project_editors.each do |p|
#         self.rightsMetadata.permissions({person: p}, 'edit')
#       end
#     end
#     # if diff between project_admins + project_editors and edit_users then remove the diff
#     edits = (com_prop.project_admins + com_prop.project_editors).uniq
#     diff = self.project.clean_edit_users - edits
#     diff.each do |d|
#       self.rightsMetadata.permissions({person: d}, 'none')
#     end
#     logger.info(self.rightsMetadata.content)
#   else
#     logger.info("permissions will be updated soon")
#   end
# end
