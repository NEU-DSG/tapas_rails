
desc "Migrate the data from the production Drupal MySQL database to the Rails MySQL database"
namespace :drupal do
  task migrate: [:environment] do
    puts "Migrating drupal database to Rails"
    client = Mysql2::Client.new(:host => "localhost", :username => "root", :database => "tapas_drupal", :password => "root")

    puts " - Truncating any existing data in users, communities, collections, and core_files tables"
    Community.delete_all
    Collection.delete_all
    CoreFile.delete_all
    User.delete_all

    puts " - Migrating users from the Drupal database to the Rails database"
    results = client.query("SELECT * FROM users WHERE uid != 0 LIMIT 10")

    results.each do |row|
      puts row["name"]
      user = User.create!(username: row["name"], email: row["mail"], password: "migration", password_confirmation: "migration")
    end

    puts " - Migrating communities from the Drupal database to the Rails database"
    results = client.query("SELECT * FROM node WHERE type = 'tapas_project' LIMIT 10")

    results.each do |row|
      puts row["nid"]
      user = User.find_by(email: "tapas_rails@tapas.neu.edu")
      community = Community.create(title: row["title"], depositor_id: user.id)
    end

    puts " - Migrating collections from the Drupal database to the Rails database"
    results = client.query("SELECT * FROM node WHERE type = 'tapas_collection' LIMIT 10")

    results.each do |row|
      puts row["nid"]
      user = User.find_by(email: "tapas_rails@tapas.neu.edu")
      community = Community.first
      collection = Collection.create(title: row["title"], depositor_id: user.id, community_id: community.id)
    end

    puts " - Migrating core files from the Drupal database to the Rails database"
    results = client.query("SELECT * FROM node WHERE type = 'tapas_record' LIMIT 10")

    results.each do |row|
      puts row["nid"]
      user = User.find_by(email: "tapas_rails@tapas.neu.edu")
      collection = Collection.first
      core_file = CoreFile.create(title: row["title"], depositor_id: user.id)
    end

  end
end
