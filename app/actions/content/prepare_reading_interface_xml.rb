# Takes a Nokogiri::XML document and the CoreFile that this xml will
# eventually be attached to and rewrites all image/link tags to point 
# at repository assets
class PrepareReadingInterfaceXML
  attr_reader :core_file, :xml, :support_file_map

  def initialize(core_file, xml)
    @core_file = core_file.reload # Ensure CoreFile is not stale
    @xml = xml
    @support_file_map = SupportFileMap.build_map @core_file
  end

  def self.execute(core_file, xml)
    self.new(core_file, xml).execute 
  end

  def execute 
    support_file_map = SupportFileMap.build_map core_file
    puts support_file_map.result
    all_relevant_attrs = %w(target url ref corresp facs)

    xml.traverse do |node| 
      node.each do |attr_name, attr_value|
        if attr_name.in?(all_relevant_attrs)
          node.set_attribute(attr_name, transform_urls(attr_value))
        end
      end
    end

    return xml
  end

  def transform_urls(urls)
    urls = urls.split(" ")
    urls.map! { |url| url = process_individual_url(url) } 
    urls.join(' ')
  end

  private 

    def process_individual_url(url)
      puts "<<<<<"
      puts "processing url #{url}" 
      puts "<<<<<"
      if url.starts_with?('#') || URI.parse(url).absolute?
        return url
        puts "URL was absolute - skipping"
      else
        filename, frag = Pathname.new(url).basename.to_s.split('#', 2)
        puts "filename was #{filename}"
        puts "frag was #{frag}"
        new_url = support_file_map.get_url(filename)
        puts "new url was #{new_url}" 
      end

      if new_url.present?
        return "#{new_url}##{frag}".chomp('#')
      else
        return url
      end
    end
end
