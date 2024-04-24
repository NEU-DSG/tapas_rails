class Collection < ActiveRecord::Base
  include Discard::Model
  include SolrHelpers

  has_and_belongs_to_many :communities
  belongs_to :depositor, class_name: "User"
  # TODO: (charles) Unclear if we need to implement this.
  # Leaving it out for now.
  # has_and_belongs_to_many :collections,
  #                         join_table: "collection_collections",
  #                         association_foreign_key: "parent_collection_id"

  has_and_belongs_to_many :core_files
  # has_many_attached :thumbnails

  after_create :add_to_solr_index
  after_update :update_solr_index
  around_destroy :delete_from_solr_index

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

  def match_dc_to_mods
    # self.DC.title = self.mods.title.first
    # self.DC.description = self.mods.abstract.first if !self.mods.abstract.blank?
    self.mods.title = self.DC.title.first
    self.mods.abstract = self.DC.description.first
    #  self.mods.thumbnail = self.DC.thumbnail.first
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
    solr_doc['edit_access_person_ssim'] = community&.project_admins.map(&:id)
    solr_doc['title_info_title_ssi'] = title
    solr_doc['table_id_ssi'] = id
    solr_doc['id'] = "#{self.class.to_s}_#{id}"
    solr_doc['access_ssim'] = is_public ? "public" : "private"
    solr_doc['thumbnail_list_tesim'] = 'public/assets/logo_no_text.png'

    solr_doc
  end

  def community
    # TODO: (charles) This makes it look like a collection belongs_to a single community,
    # but elsewhere it seems like collections can be shared. Which way should we go?
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

  # def remove_thumbnail
  #   self.thumbnails = []
  #   self.save!
  # end

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
end
