require 'thor/rails'

class ExistJetty < Thor
  include Thor::Rails
  include Thor::Actions
  
  desc "init", <<-eos
  Description:
    Given a preexisting hydra-jetty installation (rails g hydra:jetty), set up 
    an instance of eXist-db to run alongside Fedora and Solr. Settings held 
    over from cerberus_core's ExistGenerator are modified.
  Example:
    thor exist_jetty:init
  This will create:
    jetty/webapps/exist-2.2-rev.war
    jetty/contexts/exist.xml
    config/exist.yml
  eos
  
  def init
    say "Creating eXist .war file", :green
    pth = "#{::Rails.root}/jetty/webapps/exist-2.2"
    FileUtils.mkdir_p(pth) unless File.directory?(pth)
    # This is the path to the .war file created by cerberus_core's exist_generator.rb.
    old_war_path = "#{::Rails.root}/jetty/webapps/exist-2.2-rev.war"
    
    # Download the .war if necessary.
    if File.file?("#{pth}/exist-2.2-rev.war")
      say "#{pth}/exist-2.2-rev.war already exists - skipping download", :yellow
    # If the .war file is found at the out-of-date filepath, move it to new 
    #  filepath (exist-2.2 directory).
    elsif File.file?(old_war_path)
      say "Found .war at old eXist filepath - moving file to #{pth}", :yellow
      FileUtils.mv old_war_path, "#{pth}/exist-2.2-rev.war"
    else
      url = "http://librarystaff.neu.edu/DRSzip/exist-2.2-rev.war"
      get url, "#{pth}/exist-2.2-rev.war"
    end
    # If the properties files are present, consider the WAR file unpacked.
    client = "#{pth}/WEB-INF/client.properties"
    backup = "#{pth}/WEB-INF/backup.properties"
    if File.file?(client) && File.file?(backup)
      say "#{client} and/or #{backup} already exist - skipping WAR unpacking", :yellow
    else
      # Unzip WAR file.
      say "Unpacking #{pth}/exist-2.2-rev.war", :green
      run "unzip #{pth}/exist-2.2-rev.war -d #{pth}"
      # Preserve the original properties files with .template extension.
      backup_properties(client)
      backup_properties(backup)
    end
    # Change the port that eXist expects to use.
    edit_port("8080","8986",client)
    edit_port("8080","8986",backup)
    # Add context and configuration files for eXist installation.
    insert_context_file("#{::Rails.root}/jetty/contexts/exist.xml")
    insert_config_file("#{::Rails.root}/config/exist.yml")
  end
  
  no_commands do
    # Back up original eXist properties files before they are edited.
    def backup_properties(file)
      unless File.file?("#{file}.template")
        say "Backing up #{file} to #{file}.template", :green
        FileUtils.cp file, "#{file}.template"
      end
    end
    
    # Change the port referenced in a eXist properties file.
    def edit_port(oldport,newport,file)
      if File.exists?(file)
        say "Changing port #{oldport} to #{newport} in #{file}", :green
        gsub_file file, /localhost:#{oldport}/, "localhost:" + newport
      else
        say "#{file} does not exist - skipping port configuration"
      end
    end  
    
    # Add the eXist context file telling Jetty where eXist resides.
    def insert_context_file(context)
      say "Creating exist db context file", :green
      if File.exists?(context)
        say "#{context} already exists - skipping download", :yellow
        # Replace any reference to the out-of-date filepath.
        if context =~ /exist-2.2-rev.war/
          say "Replacing any references to old filepath in #{context}", :green
          gsub_file context, /exist-2.2-rev.war/, "exist-2.2/"
        end
      else
        url = "http://librarystaff.neu.edu/DRSzip/exist.xml"
        get url, "jetty/contexts/exist.xml"
      end
    end

    # Add the eXist config file telling Rails what addresses eXist uses.
    def insert_config_file(config)
      say "Creating exist db connector configuration", :green
      if File.exists?(config)
        say "#{config} already exists - skipping download", :yellow
        # Replace any references to inaccurate eXist web addresses.
        if config =~ /(db\/)(development|test|staging)/
          say "Replacing any references to eXist address in #{config}", :green
          gsub_file config, /(db\/)(development|test|staging)/, '\1apps/\2'
        end
      else
        url = "http://librarystaff.neu.edu/DRSzip/exist.yml"
        get url, "config/exist.yml"
      end
    end
  end
end