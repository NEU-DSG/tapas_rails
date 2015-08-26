# Takes a Nokogiri::XML document and the CoreFile that this xml will
# eventually be attached to and rewrites all image/link tags to point 
# at repository assets
class PrepareReadingInterfaceXML
  attr_reader :core_file, :xml, :support_file_map

  def initialize(core_file, xml)
    @core_file = core_file
    @xml = xml
    @support_file_map = SupportFileMap.build_map @core_file
  end

  def self.execute(core_file, xml)
    self.new(core_file, xml).execute 
  end

  def execute 
    support_file_map = SupportFileMap.build_map core_file
    all_relevant_attrs = %w(target url ref corresp facs xml:base)

    xml.traverse do |node| 
      all_relevant_attrs.each do |attr|
        if node[attr].present?
          all_urls = node[attr].split(" ")
          all_urls.map! do |url|
            url = process_individual_url(url)
          end

          node[attr] = all_urls.join(' ')
        end
      end
    end

    return xml
  end

  private 

    def process_individual_url(url)
      if url.starts_with? *%w(http:// https:// ftp:// #)
        return url
      else
        filename, frag = Pathname.new(url).basename.to_s.split('#', 2)
        new_url = support_file_map.get_url(filename)
      end

      if new_url.present?
        return "#{new_url}##{frag}".chomp('#')
      else
        return url
      end
    end
end
