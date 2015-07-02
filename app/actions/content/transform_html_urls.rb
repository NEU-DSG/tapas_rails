# Takes an HTMLFile object and maps all URLs within it that point at 
# images/ographies to their repository locations
class TransformHTMLUrls 
  attr_reader :html_file 

  def initialize(html_file) 
    @html_file = html_file 
  end

  def self.transform(html)
    self.new(html).transform 
  end

  def transform 
    # Build the SupportFileMap that we'll use 
    core = html_file.core_file 
    project = core.project 
    support_file_map = SupportFileMap.build_map(core, project)

    html = Nokogiri::HTML(html_file.content.content)

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

    html_file.add_file(html.to_html, 'content', html_file.filename)
    html_file.save!
  end
end
