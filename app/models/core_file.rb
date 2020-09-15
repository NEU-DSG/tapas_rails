class CoreFile < ActiveRecord::Base
  include Discard::Model

  belongs_to :depositor, class_name: "User"

  has_many :core_files_users
  has_many :authors, -> { where(user_type: 'author') }, through: :core_files_users, class_name: 'User', source: :user
  has_many :contributors, -> { where(user_type: 'contributor') }, through: :core_files_users, class_name: 'User', source: :user
  has_many :users, through: :core_files_users

  has_and_belongs_to_many :collections

  # ActiveStorage
  has_many_attached :thumbnails
  has_one_attached :canonical_object

  def self.all_ography_types
    ['personography', 'orgography', 'bibliography', 'otherography', 'odd_file',
     'placeography']
  end

  def self.all_ography_read_methods
    all_ography_types.map { |x| :"#{x}_for" }
  end

  def canonical_object_content(style="tapas-generic")
    raise "No canonical object" unless canonical_object.attached?

    xml = Nokogiri::XML(canonical_object.download)
    xslt_file = Dir[Rails.root.join("public", "view_packages", style, "*.xslt")].first
    xslt = Nokogiri::XSLT(File.read(xslt_file))

    xslt.transform(xml)
  end

  def community
    # All collections that a CoreFile belongs to will belong to the same community
    collections.first.community
  end

  def project
    # Just an alias for #community
    community
  end

  # TBH, I'm not sure how many of the methods below here and before the private
  # macro are necessary

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

  def as_json
    if upload_failed?
      render_failure_json
    elsif upload_complete?
      render_success_json
    elsif upload_in_progress?
      render_inprogress_json
    end
  end

  def is_ography?
    CoreFile.all_ography_read_methods.any? do |ography_type|
      begin
        self.send(ography_type).any?
      rescue
        return nil
      end
    end
  end

  def ography_type
    type = []
    CoreFile.all_ography_types.each do |o|
      if !self.send("#{o}_for").blank?
        type << o
      end
    end
    return type
  end

  def remove_thumbnail
    self.thumbnails = []
    self.save!
  end

  def set_authors(ids)
    CoreFilesUser.where(user_id: ids).update_all(user_type: 'author')
  end

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

  def calculate_drupal_access
    if collections.any? { |collection| collection.drupal_access == 'public' }
      self.drupal_access = 'public'
    else
      self.drupal_access = 'private'
    end
  end

  def match_dc_to_mods
    self.DC.title = self.mods.title.first
    self.DC.description = self.mods.abstract.first if !self.mods.abstract.blank?
    # self.mods.title = self.DC.title.first
    # self.mods.abstract = self.DC.description.first
    #  self.mods.thumbnail = self.DC.thumbnail.first
  end
end
