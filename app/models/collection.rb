class Collection < ActiveRecord::Base
  # include Did
  # include OGReference
  # include DrupalAccess
  # include InlineThumbnail
  # include TapasQueries
  # include StatusTracking
  # include SolrHelpers

  # before_save :ensure_unique_did
  # before_save :match_dc_to_mods
  # before_save :update_permissions
  # after_save :update_core_files

  # has_core_file_types  ["CoreFile"]
  # has_collection_types ["Collection"]

  # parent_community_relationship  :community
  # parent_collection_relationship :collection

  # has_metadata :name => "mods", :type => ModsDatastream
  # has_metadata :name => "properties", :type => PropertiesDatastream
  # has_attributes :title, datastream: "DC"
  # has_attributes :description, datastream: "DC"

  # validates_presence_of :title

  # has_many :personographies, :property => :is_personography_for,
  #   :class_name => "CoreFile"
  # has_many :orgographies, :property => :is_orgography_for,
  #   :class_name => "CoreFile"
  # has_many :bibliographies, :property => :is_bibliography_for,
  #   :class_name => "CoreFile"
  # has_many :otherographies, :property => :is_otherography_for,
  #   :class_name => "CoreFile"
  # has_many :odd_files, :property => :is_odd_file_for,
  #   :class_name => "CoreFile"
  # has_many :placeographies, :property => :is_placeography_for,
  #   :class_name => 'CoreFile'

  # Return the collection where we store TEI files that reference
  # non-existant collections.  If it doesn't exist create it.

  belongs_to :community
  belongs_to :depositor, class_name: "User"
  has_many :community_collections
  has_many :communities, through: :community_collections
  has_and_belongs_to_many :collections,
                          join_table: "collection_collections",
                          association_foreign_key: "parent_collection_id"
  has_many :thumbnails, as: :owner

  validates :depositor, :description, :title, presence: true

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

  def drupal_access=(level)
    # Because we override the methods provided by the DrupalAccess module here,
    # we need to manually ensure that the multiple: false flag is enforced on
    # set.
    error = 'Drupal access cannot have multiple values'
    raise error if level.instance_of? Array

    properties.drupal_access = level
    @drupal_access_changed = true
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

  def to_solr(solr_doc = Hash.new())
    solr_doc["active_fedora_model_ssi"] = self.class
    solr_doc["type_sim"] = "Collection"
    solr_doc['project_ssi'] = self.project.title if self.project
    solr_doc['project_pid_ssi'] = self.project.pid if self.project
    super(solr_doc)
    return solr_doc
  end

  def project
    if !self.community_id.blank?
      if Community.exists?(self.community_id)
        return Community.find(community_id)
      else
        return nil
      end
    else
      return nil
    end
  end

  def remove_thumbnail
    self.thumbnails = []
    self.save!
  end

  def update_permissions
    if self.project
      logger.info("updating permissions")
      proj_prop = self.project.properties
      if !proj_prop.project_members.blank? && (self.mass_permissions != "public" || self.project.mass_permissions != "public")
        proj_prop.project_members.each do |p|
          self.rightsMetadata.permissions({person: p}, 'read')
        end
      end
      if self.mass_permissions == "public" && self.project.mass_permissions == "public"
        self.project.read_users.each do |p|
          # if its public don't put the project_members as read users
          self.rightsMetadata.permissions({person: p}, 'none')
        end
      end
      if !proj_prop.project_admins.blank?
        proj_prop.project_admins.each do |p|
          self.rightsMetadata.permissions({person: p}, 'edit')
        end
      end
      if !proj_prop.project_editors.blank?
        proj_prop.project_editors.each do |p|
          self.rightsMetadata.permissions({person: p}, 'edit')
        end
      end
      # if diff between project_admins + project_editors and edit_users then remove the diff
      edits = (proj_prop.project_admins + proj_prop.project_editors).uniq
      diff = self.project.clean_edit_users - edits
      diff.each do |d|
        self.rightsMetadata.permissions({person: d}, 'none')
      end
      logger.info(self.rightsMetadata.content)
    else
      logger.info("permissions will be updated soon")
    end
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



  def match_dc_to_mods
    # self.DC.title = self.mods.title.first
    # self.DC.description = self.mods.abstract.first if !self.mods.abstract.blank?
    self.mods.title = self.DC.title.first
    self.mods.abstract = self.DC.description.first
    #  self.mods.thumbnail = self.DC.thumbnail.first
  end
end
