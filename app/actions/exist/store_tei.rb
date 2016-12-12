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
      did = core_file.did.to_s.gsub(':','_')
      p_did = core_file.project.did.to_s.gsub(':','_')
      url = build_url "#{p_did}/#{did}/tei"
      options = options_hash.merge({
        :headers => {
          :content_type => 'application/xml',
        }
      })

      self.resource = RestClient::Resource.new(url, options)
    end

    def execute
      build_resource
      send_request { resource.post({ file: File.open(tei_path)}) }
    end
  end
end
