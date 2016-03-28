class CoreFile < CerberusCore::BaseModels::CoreFile
  include Did
  include OGReference
  include DrupalAccess
  include TapasQueries
  include StatusTracking

  # Configure mods_display gem
  include ModsDisplay::ModelExtension
  mods_xml_source do |model|
    model.mods.content
  end

  before_save :ensure_unique_did, :calculate_drupal_access

  has_and_belongs_to_many :collections, :property => :is_member_of,
    :class_name => 'Collection'

  has_many :page_images, :property => :is_page_image_for,
    :class_name => "ImageMasterFile"
  has_many :tfc, :property => :is_tfc_for, :class_name => "TEIFile"
  has_many :html_files, :property => :is_html_for, :class_name => "HTMLFile"

  has_and_belongs_to_many :personography_for, :property => :is_personography_for,
    :class_name => 'Collection'
  has_and_belongs_to_many :orgography_for, :property => :is_orgography_for,
    :class_name => 'Collection'
  has_and_belongs_to_many :bibliography_for, :property => :is_bibliography_for,
    :class_name => 'Collection'
  has_and_belongs_to_many :otherography_for, :property => :is_otherography_for,
    :class_name => 'Collection'
  has_and_belongs_to_many :odd_file_for, :property => :is_odd_file_for,
    :class_name => 'Collection'
  has_and_belongs_to_many :placeography_for, :property => :is_placeography_for,
    :class_name => 'Collection'

  has_metadata :name => "mods", :type => ModsDatastream
  has_metadata :name => "properties", :type => PropertiesDatastream

  def self.all_ography_types
    ['personography', 'orgography', 'bibliography', 'otherography', 'odd_file',
     'placeography']
  end

  def self.all_ography_read_methods
    all_ography_types.map { |x| :"#{x}_for" }
  end

  def clear_ographies!
    CoreFile.all_ography_read_methods.each do |ography_type|
      self.send(:"#{ography_type}=", [])
    end
  end

  def retroactively_set_status!
    has_tei = canonical_object && canonical_object.content.size > 0
    teibp = nil
    self.html_files.each do |h|
      if h.html_type == "teibp"
        teibp = h
      end
    end
    has_teibp = teibp && teibp.content.size > 0
    tapas_generic = nil
    self.html_files.each do |h|
      if h.html_type == "tapas_generic"
        tapas_generic = h
      end
    end
    has_tg = tapas_generic && tapas_generic.content.size > 0
    has_collections = collections.any?

    if has_tei && has_teibp && has_tg && has_collections
      mark_upload_complete!
    else
      set_default_display_error
      mark_upload_failed!
    end
  end

  # Return the project that this CoreFile belongs to.  Necessary for easily
  # finding all of the project level ographies that exist.
  def project
    return nil if collections.blank?
    collection = collections.first
    return nil if collection.community.blank?
    return collection.community
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

  def teibp
    teibp = nil
    self.html_files.each do |h|
      if h.html_type == "teibp"
        teibp = h
      end
    end
    return teibp
  end

  def tapas_generic
    tapas_generic = nil
    self.html_files.each do |h|
      if h.html_type == "tapas_generic"
        tapas_generic = h
      end
    end
    return tapas_generic
  end

  def thumbnail
    self.content_objects.each do |c|
      if c.class == 'ImageThumbnailFile'
        return c
      else
        return nil
      end
    end
  end

  # def tfc
  #   return self.canonical_object
  # end

  def canonical_object
    full_self_id = RSolr.escape("info:fedora/#{self.pid}")
    c = ActiveFedora::SolrService.query("canonical_tesim:yes AND is_tfc_for_ssim:#{full_self_id}").first
    if c.nil?
      return false
    end

    doc = SolrDocument.new(c)
    ActiveFedora::Base.find(doc.pid, cast: true)
  end

  def content_objects
    all_possible_models = [ "ImageThumbnailFile", "ImageMasterFile", "HTMLFile",
                            "TEIFile"]

    models_stringified = all_possible_models.inject { |base, str| base + " or #{str}" }
    models_query = RSolr.escape(models_stringified)
    full_self_id = RSolr.escape("info:fedora/#{self.pid}")

    query_result = ActiveFedora::SolrService.query("active_fedora_model_ssi:(#{models_stringified}) AND (is_part_of_ssim:#{full_self_id} OR is_tfc_for_ssim:#{full_self_id} OR is_html_for_ssim:#{full_self_id} OR is_page_image_for_ssim:#{full_self_id})")

    return query_result.map { |r| r["active_fedora_model_ssi"].constantize.find(r["id"]) }
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

  def is_ography?
    CoreFile.all_ography_read_methods.any? do |ography_type|
      self.send(ography_type).any?
    end
  end

  def calculate_drupal_access
    if collections.any? { |collection| collection.drupal_access == 'public' }
      self.drupal_access = 'public'
    else
      self.drupal_access = 'private'
    end
  end
end
