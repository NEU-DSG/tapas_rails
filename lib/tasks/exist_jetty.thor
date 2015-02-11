require 'thor/rails'

class ExistJetty < Thor
  include Thor::Rails
  include Thor::Actions
  require 'net/http'
  #require 'zip'
  @@newPort = "8986"
  @@newestVers = "exist-2.2"
  oldVers = ["exist-2.2-rev"]
  
  desc "init", <<-eos
  Description:
    Given a preexisting hydra-jetty installation (rails g hydra:jetty), set up 
    an instance of eXist-db to run alongside Fedora and Solr. Settings held 
    over from cerberus_core's ExistGenerator are modified.
  Example:
    thor exist_jetty:init
  This will create:
    jetty/webapps/exist/backups/wars/exist-2.2.war
    jetty/contexts/exist-2.2.xml
    config/exist.yml
  eos
  
  def init
    say "Creating eXist .war file", :green
    # Create an eXist directory in Jetty's webapps folder, along with directories 
    #  for data backups and .war file backups.
    pth = "#{::Rails.root}/jetty/webapps/exist"
    backupDir = "#{pth}/backups"
    warDir = "#{backupDir}/wars"
    FileUtils.mkdir_p(warDir) unless File.directory?(warDir)

    # Check for - and deal with - any out-of-date file structures.
    # This is the path to the .war file created by cerberus_core's exist_generator.rb.
    cerberusPath = "#{::Rails.root}/jetty/webapps/exist-2.2-rev.war"
    # This is the path used before 1-31-2015.
    oneAppPath = "#{::Rails.root}/jetty/webapps/exist-2.2"
    contextPath = "#{::Rails.root}/jetty/contexts"
    # Reorganize the old file structure indicated by cerberusPath.
    if File.file?(cerberusPath)
      say "Found exist-2.2-rev.war at old filepath - moving file to #{warDir}", :yellow
      FileUtils.mv cerberusPath, "#{warDir}/exist-2.2-rev.war" unless File.file?("#{warDir}/exist-2.2-rev.war")
      # Delete old exist.xml and exist.yml files.
      FileUtils.rm %w(#{::Rails.root}/jetty/contexts/exist.xml #{::Rails.root}/config/exist.yml)
    # Reorganize the old file structure indicated by oneAppPath.
    elsif File.directory?(oneAppPath)
      say "Found exist-2.2 at old filepath - moving directory to #{pth}", :yellow
      FileUtils.mv "#{oneAppPath}/exist-2.2-rev.war", "#{warDir}/exist-2.2-rev.war" unless File.file?("#{warDir}/exist-2.2-rev.war")
      # Move the entire directory under #{::Rails.root}/jetty/webapps/exist.
      if not File.exists?("#{backupDir}/exist-2.2-rev.zip")
        move_dir_to_zip("#{backupDir}/exist-2.2-rev.zip", oneAppPath)
      end
      # Back up Jetty's exist.xml -> exist-2.2-rev.xml context file.
      if File.exists?("#{contextPath}/exist.xml")
        FileUtils.mv "#{contextPath}/exist.xml", "#{backupDir}/exist-2.2-rev.xml" unless File.file?("#{backupDir}/exist-2.2-rev.xml")
      end
    end
    
    # Check for - and deal with - any older versions of eXist.
    
    # Download the .war if necessary.
    if File.file?("#{warDir}/#{@@newestVers}.war")
      say "#{warDir}/#{@@newestVers}.war already exists - skipping download", :yellow
    else
      url = "http://librarystaff.neu.edu/DRSzip/#{@@newestVers}.war"
      get url, "#{warDir}/#{@@newestVers}.war"
    end
    # If the properties files are present, consider the .war file unpacked.
    client = "#{pth}/#{@@newestVers}/WEB-INF/client.properties"
    backup = "#{pth}/#{@@newestVers}/WEB-INF/backup.properties"
    if File.file?(client) && File.file?(backup)
      say "#{client} and/or #{backup} already exist - skipping WAR unpacking", :yellow
    else
      # Unzip .war file.
      say "Unpacking #{warDir}/#{@@newestVers}.war", :green
      run "unzip -q #{warDir}/#{@@newestVers}.war -d #{pth}/#{@@newestVers}"
      # Back up original eXist properties files before they are edited.
      backup_as_template(client)
      backup_as_template(backup)
    end
    # Change the port that eXist expects to use.
    edit_port("8080",@@newPort,client)
    edit_port("8080",@@newPort,backup)
    # Add context and configuration files for eXist installation.
    insert_context_file("#{contextPath}/#{@@newestVers}.xml")
    insert_config_file("#{::Rails.root}/config/exist.yml")
  end
  
  desc "set_permissions", <<-eos
  Description:
    If Jetty (with eXist) is running on the default security settings, set the 
    eXist admin password and change the database permissions within eXist.
    NOTE: This will only work if Jetty/eXist is up and running!
  Example:
    thor exist_jetty:set_permissions dsgT@pas
  eos
  
  # Change the eXist default security measures.
  def set_permissions
    newPasswd = "dsgT@pas" #ask("Enter new password for eXist admin:", :echo => false)
    say "\nReplacing default security permissions within eXist", :green
    xquery =  "<?xml version='1.0' encoding='UTF-8'?>
    <query xmlns='http://exist.sourceforge.net/NS/exist' cache='no'>
    	<text>
    		import module namespace session='http://exist-db.org/xquery/session';
    		import module namespace sm='http://exist-db.org/xquery/securitymanager';

    		let $a := if (session:set-current-user('admin','')) then
                  (: Change default password and permissions. :)
                  (sm:passwd('admin','#{newPasswd}'), 'Set admin password', sm:chmod(xs:anyURI('/db'),'rwxrwxr--'), 'Changed database permissions to: rwxrwxr--')
              		else 'Admin password is already set!'
    		return $a
    	</text>
    	<properties>
        <property name='indent' value='yes'/>
      </properties>
    </query>"
    uri = URI('http://localhost:8983')
    # Submit the XQuery fragment to eXist.
    begin
      Net::HTTP.start(uri.host, uri.port) do |http|
        response = http.post("/exist/rest/db/", 
                             xquery, 
                             {"Content-Type" => "application/xml"})
        case response
        # If the permissions have already been changed, the response will be 
        #  of type HTTPUnauthorized.
        when Net::HTTPUnauthorized then
          say "eXist admin password is already set - skipping", :yellow
        # If the request succeeds, return eXist's response in XML.
        when Net::HTTPSuccess then
          say response.body
        # All else fails, return the error and response.
        else
          say "Error setting eXist permissions: #{response.value}", :red
        end
      end
    # The above will fail if the Jetty server is not running. If so, give error
    #  message and instructions for running the task again.
    rescue
      say "#{uri} is invalid or not responding.", :red
      say "Execute 'thor exist_jetty:set_permissions' when the Jetty server is running.", :red
    end
  end
  
  no_commands do    
    # Preserve an original file as a copy with the .template extension.
    def backup_as_template(file)
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
      say "Creating exist-db context file", :green
      if File.exists?(context)
        say "#{context} already exists - skipping download", :yellow
      else
        url = "http://librarystaff.neu.edu/DRSzip/#{@@newestVers}.xml"
        get url, context
      end
    end

    # Add the eXist config file telling Rails what addresses eXist uses.
    def insert_config_file(config)
      say "Creating exist-db connector configuration", :green
      if File.exists?(config)
        say "#{config} already exists - skipping download", :yellow
        # Replace any references to inaccurate eXist web addresses.
        say "Replacing any references to old eXist address in #{config}", :green
        gsub_file config, /(db\/)(development|test|staging)/, '\1apps/\2'
      else
        url = "http://librarystaff.neu.edu/DRSzip/exist.yml"
        get url, config
      end
    end
    
    # Recursively archive the given directory. If the test of the resultant .zip
    #  file comes back OK, the original directory will be deleted.
    def move_dir_to_zip(outpath, inpath)
      say "Zipping #{inpath} to #{outpath}", :green
      run "zip -rTm #{outpath} #{inpath} -x .DS_STORE"
    end
  end
end