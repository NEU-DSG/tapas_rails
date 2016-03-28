module Content
  class UpsertReadingInterface
    attr_reader :core_file, :file_path, :interface_type
    include Content

    def self.all_interface_types
      ['teibp', 'tapas-generic']
    end

    def self.execute_all(core_file, file_path)
      all_interface_types.each do |interface_type|
        Content::UpsertReadingInterface.execute(core_file, file_path, interface_type)
      end
    end

    def self.execute(core_file, file_path, interface_type)
      self.new(core_file, file_path, interface_type).execute
    end

    def initialize(core_file, file_path, interface_type)
      @core_file = core_file
      @file_path = file_path
      @interface_type = interface_type
    end

    def execute
      ZipContentValidator.tei file_path

      interface_type_internal = interface_type.gsub('-', '_')
      html_file = nil
      # html_file = core_file.send(interface_type_internal)
      core_file.html_files.each do |h|
        if h.html_type == interface_type
          html_file = h
        end
      end

      unless html_file
        html_file = ::HTMLFile.create
        html_file.html_type = interface_type_internal
        # html_file.core_file = core_file
        html_file.html_for << core_file
        html_file.save!
      end

      filename = "#{interface_type}.xhtml"

      # Prepare the tei file for eXist by handling relative urls
      xml_updated = ::PrepareReadingInterfaceXML.execute(core_file,
        Nokogiri::XML(File.read(file_path))).to_xml

      # Pass the updated TEI File to eXist
      html = Exist::GetReadingInterface.execute(xml_updated, interface_type)

      # Add the HTML to the html_file object
      add_unique_file(html_file, :filename => filename, :blob => html)
      upsert_logger.info("HTMLFile upsert for cf #{core_file.pid} has pid #{html_file.pid}")
    end

    private
    def upsert_logger
      @@upsert_logger ||= Logger.new("#{Rails.root}/log/#{Rails.env}_upsert.log")
    end
  end
end
