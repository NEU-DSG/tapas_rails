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
    Rebuilds the reading interfaces for every TEI File uploaded to the repo

    Uses a separate 'tapas_rails_maintenance' queue to avoid clogging the main
    work queue (which handles things like processing uploads).
  eos

  def rebuild_reading_interfaces
    q = "active_fedora_model_ssi:CoreFile"

    all_dids = ActiveFedora::SolrService.query(q, fl: 'did_ssim').map do |doc|
      doc['did_ssim'].first
    end

    say "Updating #{all_dids.count} records", :blue

    all_dids.each do |did|
      Resque.enqueue(RebuildReadingInterfaceJob, did)
    end
  end
end
