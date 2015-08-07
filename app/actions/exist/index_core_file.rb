# Takes a presumed complete CoreFile and handles indexing it into exist.
module Exist
  class IndexCoreFile 
    attr_accessor :core_file, :filepath

    def initialize(core_file, filepath = nil)
      self.core_file = core_file
      self.filepath  = filepath
    end

    def self.execute(core_file, filepath = nil)
      self.new(core_file, filepath).execute
    end

    def execute
      # Index the TEI record
      did = core_file.did
      
      if filepath
        Exist::StoreTei.execute(filepath, did)
      else
        content = core_file.canonical_object.content.content
        @file = Tempfile.new(['tei', '.xml'])
        @file.write(content)
        @file.rewind
        Exist::StoreTei.execute(@file.path, did)
      end

      # Index the TFE metadata
      project_did = core_file.project.did
      collections = core_file.collections.map { |x| x.did }
      is_public   = (core_file.drupal_access == 'public').to_s
      Exist::StoreTfe.execute(did, project_did, collections, is_public)
    ensure
      @file.unlink if @file
    end
  end
end
