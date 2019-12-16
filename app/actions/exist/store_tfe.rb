# This endpoint handles adding necessary metadata to an already indexed TEI
# document that controls who is capable of viewing it.  This request can
# only be run after a TEI document with the specified drupal ID has been
# indexed in exist.
module Exist
  class StoreTfe
    include Exist::Concerns::Helpers
    attr_reader :core_file

    def initialize(core_file)
      @core_file = core_file
    end

    def self.execute(core_file)
      self.new(core_file).execute
    end

    def build_resource
      # did = core_file.did.to_s.gsub(':','_')
      did = core_file.id.to_s.gsub(':','_')
      # p_did = core_file.project.did.to_s.gsub(':','_')
      p_did = core_file.project.id.to_s.gsub(':','_')
      url = build_url "#{p_did}/#{did}/tfe"
      options = options_hash
      options[:headers][:content_type] = 'multipart/form-data'

      self.resource = RestClient::Resource.new url, options
    end

    def execute
      build_resource

      is_public = (@core_file.drupal_access == 'public').to_s
      collections = @core_file.collections.map(&:did).join(',')
      transforms = ViewPackage.where("").pluck(:dir_name).to_a #TODO replace this with available_view_packages_dir
      transforms = transforms.join(", ")
      params = { :transforms => transforms,
        :collections => collections,
        :"is-public" => is_public }

      send_request { resource.post params }
    end
  end
end
