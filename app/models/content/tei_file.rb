class TEIFile < CerberusCore::BaseModels::ContentFile 
  include Filename
  core_file_relationship :core_file

  has_and_belongs_to_many :tfc_for, :property => :is_tfc_for, 
    :class_name => "CoreFile" 
end
