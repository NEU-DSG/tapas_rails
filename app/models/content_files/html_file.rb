class HTMLFile < CerberusCore::BaseModels::ContentFile 
  core_file_relationship :core_file 

  has_and_belongs_to_many :html_for, :property => :is_html_for, 
    :class_name => "CoreFile"
end
