require 'zip'

# 'Process TEI File' is a little nebulous as an action
# What this does is send a TEI file and associated metadata
# to eXist for index and processing.  eXist then returns a single 
# zipfile holding a mods record and (currently) two different 
# HTML renditions of the TEI Record.
class ProcessTEIFile
  attr_reader :core_file # The CoreFile associated with the TEI we are 
  # processing
  attr_accessor :zip_path, :response

  def initialize(core_file)
    @core_file = core_file
    @response = {}
  end

  def self.process(core_file)
    ProcessTEIFile.new(tei_path).process
  end

  def process
    fname = core_file.canonical_object.content.label
    content = core_file.canonical_object.content.content

    request = ExistService.post('derive-all', { 
      :requests => build_xml_request, 
      :file => File.new(fname, 'wb') { |f| f.write content }
    })
  end

  # Returns an XML fragment that eXist can parse as metadata
  def build_xml_request 
    perms = (core_file.drupal_access == 'public' ? 'true' : 'false')

    request = Nokogiri::XML::Builder.new do |xml| 
      xml.request { 
        xml.send(:'doc-id', @core_file.did)
        xml.send(:'proj-id', 'hold')
        xml.send(:'is-public', perms)
        xml.collections { 
          @core_file.collections.each do |collection| 
            xml.collection collection.did 
          end
        }
      }
    end

    request.to_xml
  end
end
