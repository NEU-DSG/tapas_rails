module Exist
  class GetReadingInterface
    include Exist::Concerns::Helpers 
    attr_reader :tei_path, :type

    def initialize(tei_path, type) 
      valid_types = %w(teibp tapas-generic)

      @tei_path = tei_path 
      if type.in? valid_types
        @type = type 
      else
        raise Exceptions::ExistError.new 'Invalid reading interface type '\
          "was #{type}, must be one of: #{valid_types}"
      end
    end

    def self.execute(tei_path, type)
      self.new(tei_path, type).execute
    end

    def build_resource
      url  = build_url "derive-reader/#{type}"
      options = options_hash.merge(:headers => {
        :content_type => 'application/xml', 
        :accept => 'text/html' 
      })

      self.resource = RestClient::Resource.new(url, options)
    end

    def execute
      build_resource
      params = { 
        :file => File.read(tei_path), 
        :"assets-base" => Settings['base_url']
      }
      send_request { resource.post params }
    end
  end
end
