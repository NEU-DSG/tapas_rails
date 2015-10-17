require 'thor/rails'

class DrupalJetty < Thor 
  include Thor::Rails

  desc "init", <<-eos 
    Create jetty/solr/drupal-core/conf and populate it 
    with the required configuration files.  If they exist 
    do /not/ override them.

    If you need this to rebuild a hosed jetty/solr/drupal-core/conf directory, 
    manually delete all offending files and rerun the task.
  eos

  def init 
    unless File.directory?('/vagrant/requirements/solr-4.x')
      say 'No /vagrant/requirements/solr-4.x found.  Note that this'\
        ' task does not currently work on the production server, and'\
        ' cannot be configured to do so.', :red 
      exit 1
    end

    conf_path = "#{::Rails.root}/jetty/solr/drupal-core/conf"
    FileUtils.mkdir_p(conf_path) unless File.directory?(conf_path)

    # Insert drupal core definition if it doesn't exist 
    solr_conf_path = "#{::Rails.root}/jetty/solr/solr.xml"
    doc = Nokogiri::XML.parse File.read(solr_conf_path)
    unless doc.xpath("//core[@name='drupal']").any?
      say "Adding drupal core definition to solr.xml", :blue
      node = Nokogiri::XML::Node.new "core", doc 
      node["name"] = "drupal"
      node["instanceDir"] = "drupal-core"
      doc.at_xpath("//cores").add_child node 
      File.open(solr_conf_path, "w") { |f| f.print(doc.to_xml) } 
    else
      say "Drupal core definition already added to solr.xml - skipping", :yellow
    end


    # Copy over the three required config files from the apachesolr module
    # in drupal tapas
    druconf = "/vagrant/requirements/solr-4.x"

    safe_copy("solrconfig.xml", druconf, conf_path)
    safe_copy("protwords.txt", druconf, conf_path)
    safe_copy("schema.xml", druconf, conf_path)

    # Echo out empty (or mostly empty) files that the provided
    # drupal apachesolr config files need to actually start 
    safe_write("#{conf_path}/stopwords.txt", "")
    safe_write("#{conf_path}/synonyms.txt", "") 
    safe_write("#{conf_path}/mapping-ISOLatin1Accent.txt", "")
    safe_write("#{conf_path}/elevate.xml", "<elevate />")
  end 
 
  no_commands do 
    def safe_write(file, body)
      if File.file? file 
        say "File already exists at #{file} - skipping without write", :yellow
      else
        File.open(file, 'w') { |f| f.write body }
        say "Successfully wrote #{file}", :blue
      end
    end


    def safe_copy(fname, srcdir, trgdir)
      src_file = "#{srcdir}/#{fname}"
      trg_file = "#{trgdir}/#{fname}"

      if File.file? trg_file 
        say "File already exists at #{trg_file} - skipping without copy", :yellow
      else
        FileUtils.cp src_file, trg_file 
        say "Copied #{src_file} to #{trgdir}", :blue
      end
    end
  end
end
