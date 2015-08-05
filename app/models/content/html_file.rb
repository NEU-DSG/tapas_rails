class HTMLFile < CerberusCore::BaseModels::ContentFile 
  include Filename
  include DownloadPath

  core_file_relationship :core_file 

  has_and_belongs_to_many :html_for, :property => :is_html_for, 
    :class_name => "CoreFile"

  def html_type=(str)
    unless %(teibp tapas_generic).include? str 
      raise Exceptions::InvalidHTMLTypeError.new "HTML type must be one of: " \
        "teibp, tapas_generic" 
    end

    properties.html_type = str 
  end

  def html_type 
    properties.html_type.first
  end

  has_metadata :name => "properties", :type => PropertiesDatastream
end
