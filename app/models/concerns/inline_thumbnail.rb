# module InlineThumbnail
#   extend ActiveSupport::Concern
#
#   included do
#     include DownloadPath
#
#     has_file_datastream 'thumbnail_1',
#       :type => CerberusCore::Datastreams::FileContentDatastream
#   end
#
#   def add_thumbnail(opts)
#     # Calling .present? on a string that isn't valid UTF-8 throws an error
#     # Anything in the :content param for this is going to be an image
#     if opts[:content]
#       content = opts[:content]
#       content_present = !content.nil? && content.length > 0
#     end
#
#     if opts[:filepath].present?
#       filename = Pathname.new(opts[:filepath]).basename.to_s
#       content = IO.binread(opts[:filepath])
#     elsif opts[:name].present? && content_present
#       filename = opts[:name]
#       content  = opts[:content]
#     else
#       raise "Invalid options passed!"
#     end
#     logger.info(filename)
#     self.add_file(content, 'thumbnail_1', filename)
#     logger.info self.thumbnail_1
#     self.thumbnail_1.content = content
#     self.thumbnails = [download_path('thumbnail_1')]
#     # self.save!
#   end
# end
