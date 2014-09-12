class TEIValidator
  attr_accessor :file, :errors
  attr_reader   :tei_checker

  def initialize(file)
    @file = file
    pth = Rails.root.join("lib", "tapas_rails", "xsl_files", "isTEI.xsl")
    @tei_checker = Nokogiri::XSLT(File.read pth)
    @errors      = []
  end

  def self.validate_file(file)
    TEIValidator.new(file).validate_file 
  end

  def validate_file 
    # The error Nokogiri gives back if you try to use a binary blob
    # to build the XML is kind of blithe/opaque.  So we do some explicit
    # checking on the sort of file we're holding.

    # Ensure the file is well-formed xml
    xml_doc = Nokogiri::XML(file)
    errors.push(*xml_doc.errors.map { |x| x.to_s })
    return errors unless errors.empty?

    # Ensure the file is valid according to isTEI.xsl
    tei_checker.transform(xml_doc).children.each do |child| 
      self.errors << child.text if child.text.present? 
    end
    
    return errors || []
  end
end