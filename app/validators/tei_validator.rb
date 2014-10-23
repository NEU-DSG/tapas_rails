class TEIValidator
  attr_accessor :file, :errors
  attr_reader   :tei_checker, :css_checker

  def initialize(file)
    @file = file
    pth = Rails.root.join("lib", "tapas_rails", "xsl", "isTEI.xsl")
    css_path = Rails.root.join("lib", "tapas_rails", "xsl", "tapasCheck02.xsl")
    @tei_checker = Nokogiri::XSLT(File.read pth)
    @css_checker = Nokogiri::XSLT(File.read css_path)
    @errors      = []
  end

  def self.validate_file(file)
    TEIValidator.new(file).validate_file 
  end

  def validate_file
    # Run the given xml_document through a particular XSLT
    # check and return errors for that stage unless the file passes
    # without raising any fatal or error level exceptions.
    run_check = Proc.new do |check, document|
      check.transform(document).children.each do |child| 
        if child.text.present?
          error = { :class => child["class"], content: child.text }
          errors << error
        end
      end

      fatal_errors = %W(schematron-fatal schematron-error)
      if errors.any? { |e| fatal_errors.include? e[:class] }
        # Explicitly returning from inside the proc causes method 
        # execution to stop: this ensures that we break and return 
        # as soon as fatal errors are detected.
        return errors 
      end
    end

    # Ensure the file is well-formed xml
    xml_doc = Nokogiri::XML(file)

    xml_doc.errors.map do |error|
      error = { :class => "schematron-fatal", content: error.to_s } 
      errors << error 
    end

    return errors if errors.any?

    # Ensure the file is valid TEI 
    run_check.call(tei_checker, xml_doc)
    # Ensure the styling on the file is okay I suspect
    run_check.call(css_checker, xml_doc)

    # If we get to this point, the array is either empty 
    # or consists solely of non-fatal errors 
    errors
  end
end