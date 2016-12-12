# Sends a request to eXist to delete the file and indexing associated with the
# record with the given Drupal ID
module Exist
  class DeleteRecord
    include Exist::Concerns::Helpers

    attr_reader :did

    def initialize(did)
      @did = did
    end

    def self.execute(did)
      self.new(did).execute
    end

    def build_resource
      cf = CoreFile.find_by_did(did)
      proj_did = cf.project.did.to_s
      proj_did = proj_did.gsub(':','_')
      did = cf.did.gsub(':','_')
      url = build_url("#{proj_did}/#{did}")
      self.resource = RestClient::Resource.new(url, options_hash)
    end

    def execute
      build_resource
      send_request { resource.delete }
    end
  end
end
