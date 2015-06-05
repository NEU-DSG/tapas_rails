# Handles validating the content that we expect to be within zip files
# handed to the server during CoreFile creation. 
class ZipContentValidator 

  def self.mods(mods_path)
    validate_extension(mods_path, %w(xml), "MODS metadata")
    xml = load_and_validate_xml mods_path 

    xsd_path = "#{Rails.root}/lib/assets/xsd/mods-3-5.xsd"
    xsd = Nokogiri::XML::Schema(File.read xsd_path)

    errors = []
    xsd.validate(xml).each do |error| 
      errors << error.message
    end 

    if errors.any?
      raise Exceptions::InvalidZipError.new \
        "MODS file at #{mods_path} failed schema validation, errors were:\n "\
        "#{errors.join("\n")}"
    end
  end

  def self.html(html_path)
    validate_extension(html_path, %w(html), "HTML Display File")
  end

  def self.tei(tei_path)
    validate_extension(tei_path, %w(xml), "TEI File") 
    xml = load_and_validate_xml tei_path
    validate_tei(xml, tei_path)
  end

  def self.tfc(tfc_path)
    validate_extension(tfc_path, %w(xml), "TFC File") 
    xml = load_and_validate_xml tfc_path
    validate_tei(xml, tfc_path)
  end

  def self.support_files(support_file_paths)
    support_file_paths.each do |sf| 
      validate_extension(sf, %w(jpeg jpg png), "Page Image File")
    end
  end

  private
    def self.validate_tei(xml, path) 
      xsl_path = "#{Rails.root}/lib/assets/xslt/is_tei.xsl" 
      template = Nokogiri::XSLT(File.read(xsl_path))
      results = template.transform(xml) 

      errors = []
      
      results.xpath("p").each do |error| 
        errors << error.text
      end
      
      unless errors.empty?
        raise Exceptions::InvalidZipError.new "TEI or TFC file at #{path} did " \
          "not validate as TEI!  Errors were:\n #{errors.join("\n")}"
      end
    end

    def self.validate_extension(path, valid_exts, file_type)
      extension = path.split('.').last
      unless valid_exts.include? extension 
        raise Exceptions::InvalidZipError.new "Expected #{file_type} received"\
          "through zipfile to have one of the following extensions: "\
          "#{valid_exts}.  Instead it had extension #{extension}."
      end
    end

    def self.load_and_validate_xml(path)
      begin
        x = Nokogiri::XML(File.open(path)) do |config| 
          config.strict.nonet
        end 
      rescue Nokogiri::XML::SyntaxError => error
        raise Exceptions::InvalidZipError.new "#{path} was invalid! "\
          "Error was: #{error.message}"
      end
    end
end
