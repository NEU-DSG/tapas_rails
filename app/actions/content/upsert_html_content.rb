class UpsertHTMLContent
  include Content
  attr_reader :core_file
  attr_reader :file
  attr_reader :html_type

  def initialize(core_file, file, html_type)
    @core_file = core_file
    @file = file 
    @html_type = html_type 
  end

  def self.upsert!(core_file, file, html_type)
    self.new(core_file, file, html_type).upsert! 
  end

  def upsert! 
    begin
      unless [:teibp, :tapas_generic].include? html_type
        raise "Invalid type of html content specified" 
      end

      ZipContentValidator.html(file)

      html_object = core_file.send(html_type, :raw)

      unless html_object 
        html_object = HTMLFile.create 
        html_object.core_file = core_file 
        html_object.html_for << core_file 
        html_object.html_type = html_type.to_s
      end

      add_unique_file(html_object, file)
    ensure
      FileUtils.rm_f file 
    end
  end
end
