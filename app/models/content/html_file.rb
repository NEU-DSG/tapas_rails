class HTMLFile < CerberusCore::BaseModels::ContentFile
  include Filename
  include DownloadPath
  include TapasRails::ViewPackages

  core_file_relationship :core_file

  # FIXME: (charles) Failing because property is no longer an accepted
  # keyword
  # has_and_belongs_to_many :html_for, :property => :is_html_for,
  #   :class_name => "CoreFile"

  def html_type=(str)
    array = available_view_packages_machine
    if array.blank? # set defaults for now
      array = ["teibp", "tapas_generic"]
    end
    unless array.include? str
      raise Exceptions::InvalidHTMLTypeError.new "HTML type must be one of: " \
        "#{array.join(",")}"
    end

    properties.html_type = str
  end

  def html_type
    properties.html_type.first
  end

  # FIXME: (charles) has_metadata is no longer defined in CerberusCore
  # has_metadata :name => "properties", :type => PropertiesDatastream
end
