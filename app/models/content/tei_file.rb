class TEIFile < CerberusCore::BaseModels::ContentFile
  include Filename
  include DownloadPath

  core_file_relationship :core_file

  has_and_belongs_to_many :tfc_for, :property => :is_tfc_for,
    :class_name => "CoreFile"

  def fedora_file_path
    config_path = Rails.application.config.fedora_home
    datastream_str = "info:fedora/#{self.pid}/content/content.0"
    escaped_datastream = Rack::Utils.escape(datastream_str)
    md5_str = Digest::MD5.hexdigest(datastream_str)
    dir_name = md5_str[0,2]
    file_path = config_path + dir_name + "/" + escaped_datastream
    return file_path
  end
end
