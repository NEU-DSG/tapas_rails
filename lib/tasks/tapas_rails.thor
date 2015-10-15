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
end
