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
      proj_did = CoreFile.find_by_did(did).project.did
      url = build_url("#{proj_did.gsub!(':','_')}/#{did.gsub!(':','_')}")
      self.resource = RestClient::Resource.new(url, options_hash)
    end

    def execute
      build_resource
      send_request { resource.delete }
    end
  end
end
