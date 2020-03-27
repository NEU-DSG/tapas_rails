module CerberusCore::Datastreams
  # Implements the entire quite basic schema for Unqualified Dublin Core.
  class DublinCoreDatastream < ActiveFedora::OmDatastream
    include OM::XML::Document

    # :nodoc:
    # Boy I hate typing. AH = Attributes Hash, for the record
    AH = {namespace_prefix: 'dc'}

    set_terminology do |t|
      t.root(path: 'dc', namespace_prefix: 'oai_dc', 'xmlns:oai_dc' => 'http://www.openarchives.org/OAI/2.0/oai_dc/', 'xmlns:dc' => 'http://purl.org/dc/elements/1.1/', 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'xsi:schemaLocation' => 'http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd')
      t.title(AH)
      t.creator(AH) 
      t.subject(AH) 
      t.description(AH)
      t.publisher(AH)
      t.contributor(AH)
      t.date(AH)
      t.type(AH)
      t.format(AH)  
      t.identifier(AH)
      t.source(AH)
      t.language(AH)
      t.relation(AH)
      t.coverage(AH)
      t.rights(AH)
    end

    def prefix
      ""
    end

    def self.xml_template
      builder = Nokogiri::XML::Builder.new do |xml| 
        xml['oai_dc'].dc('xmlns:oai_dc' => 'http://www.openarchives.org/OAI/2.0/oai_dc/', 'xmlns:dc' => 'http://purl.org/dc/elements/1.1/', 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 
                      'xsi:schemaLocation' => 'http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd'){
        }
      end
      builder.doc
    end
  end
end