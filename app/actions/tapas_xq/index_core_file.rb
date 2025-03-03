# Takes a presumed complete CoreFile and handles indexing it into tapas_xq.
module TapasXq
  class IndexCoreFile
    attr_accessor :core_file, :filepath, :mod_opts

    def initialize(core_file, filepath, **mod_opts)
      self.core_file = core_file
      self.filepath  = filepath
      self.mod_opts = mod_opts
    end

    def self.execute(core_file, filepath = nil, **mod_opts)
      self.new(core_file, filepath, mod_opts).execute
    end

    def execute
      if filepath
        TapasXq::StoreTei.execute(filepath, core_file)
        TapasXq::StoreMods.execute(filepath, core_file, mod_opts)
      else
        content = core_file.canonical_object.content.content
        @file = Tempfile.new(['tei', '.xml'])
        @file.write(content)
        @file.rewind
        TapasXq::StoreTei.execute(@file.path, core_file)
        TapasXq::StoreMods.execute(@file.path, core_file, mod_opts)
      end

      TapasXq::StoreTfe.execute(core_file)
    ensure
      @file.unlink if @file
    end
  end
end
