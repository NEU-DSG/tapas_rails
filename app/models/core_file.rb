class CoreFile < CerberusCore::BaseModels::CoreFile
  include Did
  include OGReference
  include DrupalAccess
  include TapasQueries

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

  private
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
