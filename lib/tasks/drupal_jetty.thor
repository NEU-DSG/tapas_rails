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
    conf_path = "#{::Rails.root}/jetty/solr/drupal-core/conf"
    FileUtils.mkdir_p(conf_path) unless File.directory?(conf_path)

    # Copy over the three required config files from the apachesolr module
    # in drupal tapas
    druconf = "/var/www/html/tapas/sites/all/modules/apachesolr/solr-conf/solr-4.x"

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