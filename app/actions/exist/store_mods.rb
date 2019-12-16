module Exist
  class StoreMods
    include Exist::Concerns::Helpers
    include Exist::Concerns::Mods

    attr_reader :core_file

    def initialize(tei_filepath, core_file, **opts)
      @tei_filepath = tei_filepath
      @core_file = core_file
      @opts = opts
    end

    def self.execute(core_file, tei_path, **opts)
      self.new(core_file, tei_path, opts).execute
    end

    def execute
      # did = core_file.did.to_s.gsub(':','_')
      did = core_file.id.to_s.gsub(':','_')
      # p_did = core_file.project.did.to_s.gsub(':','_')
      p_did = core_file.project.id.to_s.gsub(':','_')
      url = build_url "#{p_did}/#{did}/mods"
      build_resource(url)
      send_mods_request
    end
  end
end
