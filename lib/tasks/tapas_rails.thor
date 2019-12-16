require 'thor/rails'

class TapasRails < Thor
  include Thor::Rails

  desc "create_api_user", <<-eos
    Creates the user that the Tapas Drupal site expects
    to be able to connect as.

    Loads email/api_key from the file config/tapas_api.yml
  eos

  def create_api_user
    processed  = ERB.new(File.read("#{::Rails.root}/config/tapas_api.yml")).result
    api_config = YAML.load(processed)

    u = User.new
    u.email    = api_config[::Rails.env]["email"]
    u.api_key  = api_config[::Rails.env]["api_key"]
    u.password = api_config[::Rails.env]["password"]

    if User.exists?(:email => u.email)
      say "User #{u.email} already exists, nothing to do...", :yellow
    else
      u.save!
      say "User #{u.email} created successfully!", :blue
    end
  end

  desc 'rebuild_reading_interfaces', <<-eos
    Rebuilds the reading interfaces for every TEI File uploaded to the repo.

    Uses a separate 'tapas_rails_maintenance' queue to avoid clogging the main
    work queue (which handles things like processing uploads).  Can specify a
    number of rows to process over, default is set to 500.
  eos

  def rebuild_reading_interfaces(rows=500)
    q = "active_fedora_model_ssi:CoreFile"

    say "Requesting #{rows} IDS from solr for rebuid", :blue

    all_dids = ActiveFedora::SolrService.query(q, fl: 'id', rows: rows).map do |doc|
      doc['id']
    end

    say "Updating #{all_dids.count} records", :blue

    all_dids.each do |did|
      Resque.enqueue(RebuildReadingInterfaceJob, did)
    end
  end

  desc 'create_view_packages', <<-eos
    Enqueues the create view packages job to load the assets on each deploy
  eos

  def create_view_packages()
    say "creating view packages", :blue

    Resque.enqueue(GetViewPackagesFromGithub)
  end
  
end
