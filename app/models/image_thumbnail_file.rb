class ImageThumbnailFile < ActiveRecord::Base
  include Filename
  include DownloadPath

  # core_file_relationship :core_file

  # has_file_datastream 'thumbnail_1',
  #   :type => CerberusCore::Datastreams::FileContentDatastream
end
