# Takes a Nokogiri::HTML document and the CoreFile that this html will 
# eventually be attached to and rewrites all image/link tags to point 
# at repository assets
class TransformHTMLUrls 
  attr_reader :core_file, :html

  def initialize(core_file, html) 
    @core_file = core_file
    @html = html
  end

  def self.transform(core_file, html)
    self.new(core_file, html).transform 
  end

  def transform 
    support_file_map = SupportFileMap.build_map core_file

    all_links = html.css('a, img')

    puts "counted #{all_links.count} links"
    all_links.each do |link| 
      if link['href'].present?
        url = link['href']
      elsif link['src'].present?
        url = link['src'] 
      else 
        next
      end

      # Don't attempt to change absolute urls to web resources
      next if url.starts_with?('http://', 'https://', 'ftp://', '#')

      filename = Pathname.new(url).basename.to_s
      new_url = support_file_map.get_url filename

      if new_url 
        link['href'] = new_url if link['href'].present? 
        link['src'] = new_url if link['src'].present? 
      end
    end

    return html
  end
end
