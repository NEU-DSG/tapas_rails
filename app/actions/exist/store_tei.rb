module Exist
  class StoreTei 
    attr_reader :tei_path, :did
    include Exist::Concerns::Helpers

    def initialize(tei_path, did)
      @tei_path = tei_path 
      @did = did 
    end

    def self.execute(tei_path, did) 
      self.new(tei_path, did).execute
    end

    def build_resource 
      url = build_url "#{did}/tei" 
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

