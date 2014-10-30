class TEIMetadataExtractor
  attr_accessor :response, :source_file, :transformed_file
  attr_reader   :metadata_extractor


  def initialize(file)
    @source_file      = Nokogiri::XML(file)
    path = Rails.root.join("lib", "tapas_rails", "xsl", "tfc.xsl")
    @metadata_extractor = Nokogiri::XSLT(File.read path)

    @transformed_file = @metadata_extractor.transform @source_file
    @response = {}
  end

  def self.extract(file)
    TEIMetadataExtractor.new(file).extract 
  end

  def extract
    response.merge! handle_title
    response.merge! handle_rights
    response.merge! handle_source
    response.merge! handle_language
    response.merge! handle_publish_date
    response.merge! handle_creator
    response.merge! handle_contributors
    return response
  end

  def handle_title
    elements = extract_element "dc_title"
    puts elements
    if elements.first.present?
      title = elements.first 
      title = "#{title[0..252]}..." if (title.length >= 255)
    else
      title = "Please give your TEI file a valid title and " + 
              "reupload the file."
    end

    return { title: title }
  end

  def handle_rights
    elements = extract_element "dc_rights"
    elements.first.present? ? { rights: elements.first } : {}
  end

  def handle_source
    elements = extract_element "dc_source" 
    elements.first.present? ? { source: elements.first } : {}
  end

  def handle_language
    elements = extract_element "dc_language" 
    if elements.first.present?
      language = elements.first 
      language = language[/[a-zA-Z][a-zA-Z][a-zA-Z]/] || language
      { language: language }
    else
      {}
    end
  end

  def handle_publish_date 
    elements = extract_element "dc_date" 
    # Make Ruby's built-in date processing do the transformation
    # and if it can't assume the user did something heinous
    # and return nothing 
    if elements.first.present?
      date = elements.first 
      begin 
        date = DateTime.parse(date).to_s(:db)
        { date: date }
      rescue ArgumentError => error
        {}
      end
    else
      {}
    end
  end

  def handle_contributors
    elements = extract_element "dc_contributor" 
    elements.any? ? { contributors: elements } : {}
  end

  def handle_creator
    elements = extract_element "dc_creator"
    elements.any? ? { creator: elements.first } : {} 
    # The logic for the current set creator action is not worth the 
    # headache of maintaining.
  end

  private 

    def extract_element(element_name)
      query_node = transformed_file.xpath("//tapas_metadata/#{element_name}")
      result     = []

      query_node.each do |node| 
        if node.text.present? 
          result << node.text 
        end
      end

      return result
    end
end