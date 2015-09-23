# Takes a filepath pointing at a TEI XML document and sends it to eXist.
# Returns a raw string of the resulting XML data.
# Does not move, delete, modify, or validate the file you provide.
module Exist
  class GetMods
    include Exist::Concerns::Helpers
    include Exist::Concerns::Mods

    def initialize(tei_filepath, **opts)
      @tei_filepath = tei_filepath
      @opts         = opts
    end

    def self.execute(tei_filepath, **opts)
      self.new(tei_filepath, opts).execute
    end

    def execute
      build_resource(build_url('derive-mods'))
      send_mods_request
    end
  end
end
