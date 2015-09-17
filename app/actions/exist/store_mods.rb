module Exist
  class StoreMods 
    attr_reader :tei_path, :core_file
    include Exist::Concerns::Helpers

    def initialize(core_file, tei_path)
      @core_file = core_file 
      @tei_path  = tei_path
    end

    def self.execute(core_file, tei_path)
      self.new(core_file, tei_path).execute
    end

    def build_resource
      url = build_url "#{core_file.project.did}/#{core_file.did}/mods"
      hash = options_hash

      hash[:headers][:content_type] = "multipart/form-data"
      hash[:headers][:accept] = "application/xml" 

      self.resource = RestClient::Resource.new(url, hash) 
    end

    def execute
      build_resource
      send_request { resource.post({ file: File.read(tei_path)}) } 
    end
  end
end

