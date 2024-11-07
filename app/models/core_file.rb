# frozen_string_literal: true

class CoreFile < ActiveRecord::Base
  include Discard::Model
  include SolrHelpers

  # Associations
  belongs_to :depositor, class_name: "User"
  belongs_to :collection
  has_many :project_core_files
  # TODO: create logic such that deleting a core file by removing it from it's sole collection will also delete the reference
  # to it and the collection's parent project on the project_core_files join table; once there is no reference on the join
  # table between a core file and a project, the core file can be deleted along with it's records on the collection_core_files
  # join table
  has_many :projects, through: :project_core_files
  has_many :collection_core_files
  has_many :collections, through: :collection_core_files
  # TODO: create logic to delete project_core_file reference when all the parent collections have been deleted
  has_many :image_files, as: :imageable
  has_and_belongs_to_many :users

  # Callbacks
  after_save :update_solr_index
  before_destroy :delete_from_solr_index
  after_save :add_project_core_file_ref
  # TODO: test to determine whether a separate callback is needed to remove project_core_file reference after a core file's
  # parent collection has been deleted from the project and not added to a different parent collection


  # after_create :associate_with_project

  # these strings refer to the role of the file in collection(s);
  # if the user doesn't select an ography type, the file is not a support file but is still a tei file that
  # will need to be parsed for urls and have a map generated with the urls for the file;
  # this should be done by initializing SupportFileMap with the core_file object itself as a parameter, then passing
  # the support_file_map instance to SupportFileMap.build_map
  def self.all_ography_types
    %w[personography orgography bibliography otherography odd_file placeography]
  end

  def self.all_ography_read_methods
    all_ography_types.map { |x| :"#{x}_for" }
  end

  def authors
    users.where(core_files_users: { user_type: "author" })
  end

  def authors=(user_ids)
    user_ids.reject(&:blank?).each do |user_id|
      CoreFilesUser.find_or_create_by(core_file_id: id, user_id: user_id, user_type: "author")
    end
  end

  def contributors
    users.where(core_files_users: { user_type: "contributor" })
  end

  def contributors=(user_ids)
    user_ids.reject(&:blank?).each do |user_id|
      CoreFilesUser.find_or_create_by(core_file_id: id, user_id: user_id, user_type: "contributor")
    end
  end

  def collections=(collection_ids)
    collection_ids.reject(&:blank?).each do |collection_id|
      collections << Collection.find(collection_id)
    end
  end

  def project
    # All collections that a CoreFile belongs to will belong to the same project
    collections.first.project
  end

  def add_project_core_file_ref
    p = project

    ProjectCoreFile.find_or_create_by(project_id: p.id, core_file_id: id)
  end

  def clear_ographies!
    CoreFile.all_ography_read_methods.each do |ography_type|
      begin
        self.send(:"#{ography_type}=", [])
      rescue
        return nil
      end
    end
  end

  def retroactively_set_status!
    array = available_view_packages_machine
    create_view_package_methods
    views = 0
    array.each do |view_package|
      view = send("#{view_package}".to_sym)
      if !(view && view.content.size > 0)
        views = views + 1
      end
    end

    has_tei = canonical_object && canonical_object.content.size > 0
    has_collections = collections.any?

    if has_tei && views == 0 && has_collections
      mark_upload_complete!
    else
      set_default_display_error
      mark_upload_failed!
    end
  end

  def create_view_package_methods
    array = available_view_packages_machine

    array.each do |method_name|
      string_name = method_name
      method_name = method_name.to_sym
      CoreFile.send :define_method, method_name do |arg = :models|
        if arg.blank?
          arg = :models
        end
        tg = self.content_objects(:raw).find do |x|
          #change this to whatever field name replaced "active_fedora_model_ssi"
          x["active_fedora_model_ssi"] == "HTMLFile" &&
            x["html_type_ssi"] == string_name
        end

        load_specified_type(tg, arg)
      end
    end
  end

  # Check to see if this is an ography-type upload or a tei file type upload
  def file_type
    if is_ography?
      :ography
    else
      :tei_content
    end
  end

  def as_json
    if upload_failed?
      render_failure_json
    elsif upload_complete?
      render_success_json
    elsif upload_in_progress?
      render_inprogress_json
    end
  end

  def match_dc_to_mods
    self.DC.title = self.mods.title.first
    self.DC.description = self.mods.abstract.first if !self.mods.abstract.blank?
    # self.mods.title = self.DC.title.first
    # self.mods.abstract = self.DC.description.first
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

  def to_solr
    {
      'active_record_model_ssi' => self.class.to_s,
      'depositor_tesim' => self.depositor_id,
      'table_id_ssi' => id,
      'id' => "#{self.class.to_s}_#{id}",
      'edit_access_person_ssim' => project.project_admins.map(&:id),
      # these two replace the is_member_of_ssim field
      'collections_ssim' => self.collections.map(&:id),
      'projects_ssim' => self.collections.map(&:project_id),
      'title_info_title_ssi' => title,
      'creator_tesim' => nil, # name of person who uploaded file
      'personal_creators_tesim' => nil, # name of person who uploaded file
      'all_text_timv' => nil, #TODO: review the pre-Archimedes conception of canonical object and determine if it is still useful for revamp; self.canonical_object.content.content if self.canonical_object
      # 'ography' refer to this support file's "ography role" in the collection as one of the types of ography files; it should have an array of the ids of the collections to which it serves as that type of file:
      'type_ssim' => self.is_ography? ? self.ography_type : 'TEI Record',
      'is_ography_for_ssim' => is_ography_for,
      # odd is an acronym, 'one file does it all', it refers to a file that serves to expand on how to create the xml schema; not currently supported but will be in a future update
      # 'is_odd_file_for_ssim' => nil
    }
  end

  def is_ography?
    self.ography_type
  end

  def is_ography_for
    is_ography?.nil? ? [] : collection_ids
  end

  # def remove_thumbnail
  #   self.thumbnails = []
  #   self.save!
  # end

  private

  def render_failure_json
    { :status => upload_status,
      :errors_display => errors_display,
      :errors_system => errors_system,
      :stacktrace => stacktrace,
      :since => upload_status_time
    }
  end

  def render_inprogress_json
    { :status => upload_status,
      :since  => upload_status_time }
  end

  def render_success_json
    tei_name = (canonical_object ? canonical_object.filename : '')

    { :status => upload_status,
      :since => upload_status_time,
      :collection_dids => collections.map(&:did),
      :tei => tei_name,
      :support_files => page_images.map(&:filename),
      :depositor => depositor,
      :access => drupal_access
    }
  end

  # may refactor this method to check the project_core_file join table to ensure the association exists
  # def associate_with_project
  #   if collection&.project
  #     self.projects << collection.project
  #   end
  # end

  # def calculate_drupal_access
  #   if collections.any? { |collection| collection.drupal_access == 'public' }
  #     self.drupal_access = 'public'
  #   else
  #     self.drupal_access = 'private'
  #   end
  # end
end
