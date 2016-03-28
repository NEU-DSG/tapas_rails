# This model handles building a map of filenames to download urls in the
# repository, which is used to modify the URLs in a teibp/tapas_generic
# html rendition of a TEI file returned from eXist.  To avoid potential
# collisions, each source of support files (currently just page images
# associated with an individual TEI File and *ography objects associated
# with Collections) is mapped to a different key in the hash.  File level
# support files are sent to map[:file][filename_here] while project level
# support files are sent to map[:collection][filename_here].
#
# In the case where the :file and :project scope both have a support file
# with a given name we always load the :file level url.
class SupportFileMap
  attr_reader :core_file
  attr_accessor :result

  def initialize(core_file)
    @core_file = core_file
    @result = {}
  end

  def self.build_map(core_file)
    s = SupportFileMap.new(core_file)
    s.build_map
    return s
  end

  def build_map
    build_map_scope(:file, core_file.page_images)
    build_map_scope(:collection, core_file.all_ography_tei_files)
  end

  def get_url(filename)
    return result[:file][filename] if result[:file][filename]
    return result[:collection][filename] if result[:collection][filename]
  end

  def download_url(page_image)
    path = Pathname.new Settings['base_url']
    path.join('downloads', page_image.pid, '?datastream_id=content').to_s
  end

  private
    def build_map_scope(scope, all_af_objects)
      result[scope] = {}
      all_af_objects.each do |content|
        result[scope][content.filename] = download_url content
      end
    end
end
