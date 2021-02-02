class CoreFile < ActiveRecord::Base
  include Discard::Model
  include TapasRails::ViewPackages

  belongs_to :depositor, class_name: 'User'

  has_many :core_files_users
  has_many :authors, -> { where(core_files_users: { user_type: 'author' }) }, through: :core_files_users, class_name: 'User', source: :user
  has_many :contributors, -> { where(core_files_users: { user_type: 'contributor' }) }, through: :core_files_users, class_name: 'User', source: :user
  has_many :users, through: :core_files_users

  has_and_belongs_to_many :collections

  # ActiveStorage
  has_many_attached :thumbnails
  has_one_attached :canonical_object

  before_update :set_privacy

  def self.all_ography_types
    %w[personography orgography bibliography otherography odd_file placeography]
  end

  def self.all_ography_read_methods
    all_ography_types.map { |x| :"#{x}_for" }
  end

  def community
    # All collections that a CoreFile belongs to will belong to the same community
    collections.first.community rescue nil
  end

  def project
    # Just an alias for #community
    community
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

  # Check to see if this is an ography-type upload or a tei file type
  # upload
  def file_type
    if is_ography?
      :ography
    else
      :tei_content
    end
  end

  def is_ography?
    CoreFile.all_ography_read_methods.any? do |ography_type|
      send(ography_type).any? rescue return nil
    end
  end

  def ography_type
    CoreFile.all_ography_types.map do |o|
      o unless send("#{o}_for").blank?
    end.compact
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
          x['active_fedora_model_ssi'] == 'HTMLFile' &&
            x['html_type_ssi'] == string_name
        end

        load_specified_type(tg, arg)
      end
    end
  end

  def self.remove_view_package_methods(view_packages)
    view_packages.each do |r|
      if !r.blank?
        sym = r.to_sym
        if CoreFile.method_defined? sym
          CoreFile.send :remove_method, sym
        end
      end
    end
  end

  def remove_thumbnail
    update(thumbnails: [])
  end

  def set_authors(ids)
    CoreFilesUser.where(user_id: ids).update_all(user_type: 'author')
  end

  def set_privacy
    self.is_public = false unless collections.any?(&:is_public)
  end

  #############################################################################
  #
  # Notes on an ETL integration with eXist
  #
  # This area is meant to describe what a basic integration of eXist can look
  # like using the ExistService at services/exist_service.rb so that the MySQL
  # database is continually kept in sync with
  #
  # The general strategy will be to keep the MySQL data in sync with the eXist
  # database, using MySQL as the single source of truth (SSOT) for the data
  # while taking advantage of the extended capabilities of eXist. On the CoreFile
  # data model, as long as this solution is scalable (i.e. the rate of files
  # entered into TAPAS doesn't cause latency issues with eXist), the data will
  # be kept in realtime sync with the eXist database.
  #
  # after_create_commit :etl_exist_create
  # after_update_commit :etl_exist_update
  # after_delete_commit :etl_exist_delete
  #
  # def etl_exist_create
  #   # Sync creating eXist content
  #   ExistService.post()
  # end
  # def etl_exist_update
  #   # Sync updating eXist content
  #   ExistService.post()
  # end
  # def etl_exist_delete
  #   # Sync deleting eXist content
  #   ExistService.delete()
  # end
  #
  #############################################################################
end
