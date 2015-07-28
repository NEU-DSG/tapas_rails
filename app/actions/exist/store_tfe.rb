# This endpoint handles adding necessary metadata to an already indexed TEI 
# document that controls who is capable of viewing it.  This request can 
# only be run after a TEI document with the specified drupal ID has been 
# indexed in exist.
module Exist
  class StoreTfe 
    include Exist::Concerns::Helpers 
    attr_reader :did, :project_did, :collection_dids, :is_public 

    def initialize(did, proj_id, collections, is_public)
      @did = did 
      @project_did = proj_id 
      if collections.is_a? Array 
        collections = collections.join(',') 
      end
      @collection_dids = collections 
      @is_public = is_public 
    end

    def self.execute(did, project_did, collection_dids, is_public)
      self.new(did, project_did, collection_dids, is_public).execute
    end

    def build_resource
      url = build_url "#{did}/tfe" 
      options = options_hash
      options[:headers][:content_type] = 'multipart/form-data' 

      self.resource = RestClient::Resource.new url, options 
    end

    def execute 
      build_resource 

      params = { :"proj-id" => project_did,
        :collections => collection_dids, 
        :"is-public" => is_public }

      send_request { resource.post params }
    end
  end
end

