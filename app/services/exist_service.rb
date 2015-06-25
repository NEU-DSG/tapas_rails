# Things that the Exist Service needs to be able to do 
# - Ask eXist-db for a MODS record generated from a given TEI file 
# - Ask eXist-db to perform a full record index 
#   - Index given TEI File 
#   - Return a TEIBP/Tapas Generic representations of the object
#   - Return the MODS metadata associated with this object 
# - Ask eXist-db to unindex a given record
class ExistService
  def self.post(url_frag, payload)
    RestClient.post(build_url(url_frag), payload, build_authorization_header)  
  end

  def self.get(url_frag)
    RestClient.get(build_url(url_frag), build_authorization_header)
  end

  def self.delete(url_frag)
    RestClient.delete(build_url(url_frag), build_authorization_header)
  end

  private
    def self.exist_base
      conf_file = "#{Rails.root}/config/exist.yml"
      config = YAML.load(File.read conf_file)
      base_url = config[Rails.env]['base_path']

      if URI.parse(base_url).absolute?
        base_url
      else
        raise "Relative or invalid URL detected in #{conf_file} "\
          "Please fix before attempting to communicate with eXist again"
      end
    end

    def self.build_authorization_header 
      {}
    end
  
    def self.build_url(relative_path)
      "#{exist_base}/#{relative_path}"
    end
end
