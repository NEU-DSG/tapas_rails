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
    result[:file_level] = {}
    core_file.page_images.each do |page_image| 
      result[:file_level][page_image.content.label] = download_url page_image
    end
  end

  def create_project_level_map 

  end

  def download_url(page_image)
    path = Pathname.new(base_url)
    path.join('downloads', page_image.pid, '?datastream_id=content').to_s
  end
end
