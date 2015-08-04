class ImageMasterFile < CerberusCore::BaseModels::ContentFile
  include Filename
  include DownloadPath

  core_file_relationship :core_file

  has_and_belongs_to_many :page_image_for, :property => :is_page_image_for, 
    :class_name => "CoreFile" 
end
