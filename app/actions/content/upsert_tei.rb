module Content
  class UpsertTei
    attr_reader :core_file
    attr_reader :file

    include Content

    def initialize(core_file, file)
      @core_file = core_file
      @file = file 
    end

    def self.execute(core_file, file)
      self.new(core_file, file).upsert!
    end

    def upsert! 
      ZipContentValidator.tei file

      content = core_file.canonical_object

      unless content 
        content = TEIFile.create
        content.canonize
        content.core_file = core_file
        content.save! 
      end

      add_unique_file(content, :filepath => file)
    end
  end
end
