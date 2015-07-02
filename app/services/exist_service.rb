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
    def self.build_authorization_header 
      {}
    end
  
    def self.build_url(relative_path)
      "#{Settings['exist']['url']}/#{relative_path}"
    end
end
