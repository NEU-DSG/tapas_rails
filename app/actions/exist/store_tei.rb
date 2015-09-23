module Exist
  class StoreTei 
    attr_reader :tei_path, :core_file
    include Exist::Concerns::Helpers

    def initialize(tei_path, core_file)
      @tei_path = tei_path 
      @core_file = core_file
    end

    def self.execute(tei_path, core_file)
      self.new(tei_path, core_file).execute
    end

    def build_resource 
      url = build_url "#{core_file.project.did}/#{core_file.did}/tei" 
      options = options_hash.merge({ 
        :headers => { 
          :content_type => 'application/xml', 
        }
      })

      self.resource = RestClient::Resource.new(url, options)
    end

    def execute 
      build_resource
      send_request { resource.put File.read(tei_path) }
    end
  end
end

