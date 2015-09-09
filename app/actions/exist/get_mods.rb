# Takes a filepath pointing at a TEI XML document and sends it to eXist.
# Returns a raw string of the resulting XML data.
# Does not move, delete, modify, or validate the file you provide.
module Exist
  class GetMods
    include Exist::Concerns::Helpers

    attr_reader :tei_filepath, :opts

    def initialize(tei_filepath, **opts)
      @tei_filepath = tei_filepath
      @opts         = opts
    end

    def self.execute(tei_filepath, **opts)
      self.new(tei_filepath, opts).execute
    end

    def build_resource 
      url = build_url 'derive-mods'
      hash = options_hash 

      puts url

      hash[:headers][:content_type] = 'multipart/form-data'
      hash[:headers][:accept] = 'application/xml'

      self.resource = RestClient::Resource.new(url, hash)
    end

    def execute
      build_resource

      contributors, authors = nil

      post_params = {}
      post_params[:file] = File.new(tei_filepath, 'rb')

      if opts[:contributors].present?
        post_params[:displayContributors] = opts[:contributors].join(' | ')
      end

      if opts[:authors].present?
        post_params[:displayAuthors] = opts[:authors].join(' | ')
      end

      if opts[:date].present?
        post_params[:timelineDate] = opts[:date]
      end

      if opts[:title].present?
        post_params[:displayTitle] = opts[:title]
      end

      puts post_params

      send_request { resource.post post_params }
    end
  end
end
