class UpsertXMLContent 
  attr_reader :core_file
  attr_reader :file
  attr_reader :xml_type

  include Content

  def initialize(core_file, file, xml_type)
    @core_file = core_file
    @file = file 
    @xml_type = xml_type
  end

  def self.upsert!(core_file, file, xml_type)
    self.new(core_file, file, xml_type).upsert!
  end

  def upsert! 
    begin
      unless [:tei, :tfc].include? xml_type
        raise "Invalid type of XML content specified" 
      end

      ZipContentValidator.send(xml_type, file)

      if xml_type == :tei 
        content = core_file.canonical_object
      elsif xml_type == :tfc
        content = core_file.tfc.first
      end

      unless content 
        content = TEIFile.create
        xml_type == :tei ? content.canonize : content.tfc_for << core_file
        content.core_file = core_file
        content.save! 
      end

      add_unique_file(content, file)
    ensure
      FileUtils.rm_f file
    end
  end
end
