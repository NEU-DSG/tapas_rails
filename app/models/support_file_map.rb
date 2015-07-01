# This action handles building a map of filenames to download urls in the 
# repository, which is used to modify the URLs in a teibp/tapas_generic 
# html rendition of a TEI file returned from eXist.  To avoid potential 
# collisions, each source of support files (currently just page images 
# associated with an individual TEI File and *ography objects associated 
# with a Project) is mapped to a different key in the hash.  File level 
# support files are sent to map[:file][filename_here] while project level 
# support files are sent to map[:project][filename_here].  
#
# What to do in the case where a project level support file and a TEI File 
# level support file have the same name is an arbitrary decision.  The one 
# I have currently made is to always prefer loading the URL specified at the 
# file level.
class BuildSupportFileMap 
  attr_reader :base_url, :core_file, :project
  attr_accessor :result

  def initialize(core_file, project)
    conf_file = "#{Rails.root}/config/support_file_map.yaml"
    @base_url = YAML.load(File.read(conf_file))[Rails.env]
    @core_file = core_file
    @project = project
    @result = {}
  end

  def self.build_map(core_file, project) 
    BuildSupportFileMap.new(core_file, project).build_map
  end

  def build_map
    create_file_level_map
    create_project_level_map
  end

  def create_file_level_map 
    result[:file] = {}
    core_file.page_images.each do |page_image| 
      result[:file][page_image.content.label] = download_url page_image
    end
  end

  def create_project_level_map 
    result[:project] = {}
  end

  def download_url(page_image)
    path = Pathname.new(base_url)
    path.join('downloads', page_image.pid, '?datastream_id=content').to_s
  end
end
