require 'net/http'
require 'json'
require 'csv'

# Notes about the migration tables at https://docs.google.com/document/d/1KbB44saOBg7jFyDdMe_6gMT1XombFK6BDufTspZ2N0o/edit?usp=sharing

# Set Rails logger to log to std out while running migration
Rails.logger = Logger.new(STDOUT)
Rails.logger.level = Logger::DEBUG
logger = Rails.logger

desc "Migrate the data from the production Drupal MySQL database to the Rails MySQL database"
namespace :drupal do
  task migrate: [:environment] do
    logger.info "Migrating drupal database to Rails"
    client = Mysql2::Client.new(:host => "localhost", :username => ENV['DRUPAL_MYSQL_USER'], :database => ENV['DRUPAL_MYSQL_DB_NAME'], :password => ENV['DRUPAL_MYSQL_PASSWORD'])

    # Clear existing DB for migration
    logger.info " - Truncating any existing data in institutions, users, communities, collections, core_files, and pages tables"
    Institution.delete_all
    Community.delete_all
    Collection.delete_all
    CoreFile.delete_all
    User.delete_all
    Page.delete_all


    # Migrate institutions
    logger.info " - Migrating institutions from the Drupal database to the Rails database"

    # Save Drupal <> Rails ids as hash for later lookup
    institutions_drupal_to_rails_ids = {}

    # Query all institutions saved as taxonomy terms in Drupal
    results = client.query("SELECT * FROM taxonomy_term_data WHERE vid = 2")
    results.each do |row|
      logger.info " -- #{row["tid"]} #{row["name"]}"

      institution = Institution.new
      institution.name = row["name"]

      # set description from field_data_field_tapas_description.field_tapas_description_value
      description_results = client.query("SELECT field_tapas_description_value FROM field_data_field_tapas_description WHERE entity_id = #{row['tid']}")
      description_results.each do |description_row|
        if description_row['field_tapas_description_value']
          institution.description = description_row['field_tapas_description_value']
        end
      end

      # set address from field_data_field_institution_address.field_institution_address_value
      address_results = client.query("SELECT field_institution_address_value FROM field_data_field_institution_address WHERE entity_id = #{row['tid']}")
      address_results.each do |address_row|
        if address_row['field_institution_address_value']
          institution.address  = address_row['field_institution_address_value']
        end
      end

      # set latitude from field_data_field_institution_latitude.field_institution_latitude_value
      latitude_results = client.query("SELECT field_institution_latitude_value FROM field_data_field_institution_latitude WHERE entity_id = #{row['tid']}")
      latitude_results.each do |latitude_row|
        if latitude_row['field_institution_latitude_value']
          institution.latitude  = latitude_row['field_institution_latitude_value']
        end
      end

      # set longitude from field_data_field_institution_longitude.field_institution_longitude_value
      longitude_results = client.query("SELECT field_institution_longitude_value FROM field_data_field_institution_longitude WHERE entity_id = #{row['tid']}")
      longitude_results.each do |longitude_row|
        if longitude_row['field_institution_longitude_value']
          institution.longitude  = longitude_row['field_institution_longitude_value']
        end
      end

      # set longitude from field_data_field_institution_longitude.field_institution_longitude_value
      longitude_results = client.query("SELECT field_institution_longitude_value FROM field_data_field_institution_longitude WHERE entity_id = #{row['tid']}")
      longitude_results.each do |longitude_row|
        if longitude_row['field_institution_longitude_value']
          institution.longitude  = longitude_row['field_institution_longitude_value']
        end
      end

      # set url from field_data_field_institution_url.field_institution_url_url
      url_results = client.query("SELECT field_institution_url_url FROM field_data_field_institution_url WHERE entity_id = #{row['tid']}")
      url_results.each do |url_row|
        if url_row['field_institution_url_url']
          institution.url  = url_row['field_institution_url_url']
        end
      end


      # TODO: #institutions - determine if the official flag needs to be migrated since it's not in the Rails data model for institutions
      # | field_data_field_institution_official_flag      |

      # TODO: #staticfiles Set image for institution from field_data_field_institution_image when static file solution is completed

      institution.save
      institutions_drupal_to_rails_ids[row["tid"]] = institution.id
    end


    # Migrate users
    logger.info " - Migrating users from the Drupal database to the Rails database"

    # Save Drupal <> Rails ids as hash for later lookup
    users_drupal_to_rails_ids = {}

    results = client.query("SELECT * FROM users WHERE uid != 0")
    results.each do |row|
      logger.info " -- #{row["uid"]} #{row["name"]}"
      # create user with migration passwords
      user = User.new

      user.username = row["name"]
      user.email = row["mail"]
      user.password = "migration"
      user.password_confirmation = "migration"

      # Don't send an email to the user on migration
      user.skip_confirmation!

      # set user bio from field_data_field_profile_about.field_profile_about_value
      bio_results = client.query("SELECT field_profile_about_value FROM field_data_field_profile_about WHERE entity_id = #{row['uid']}")
      bio_results.each do |bio_row|
        if bio_row['field_profile_about_value']
          user.bio = bio_row['field_profile_about_value']
        end
      end

      # set user institution from field_data_field_profile_institution.field_profile_institution_tid join
      institution_results = client.query("SELECT field_profile_institution_tid FROM field_data_field_profile_institution WHERE entity_id = #{row['uid']}")
      institution_results.each do |institution_row|
        if institution_row['field_profile_institution_tid']
          institution_data_results = client.query("SELECT name FROM taxonomy_term_data WHERE tid = #{institution_row['field_profile_institution_tid']}")

          institution_name = ''
          institution_data_results.each do |institution_data_row|
            if institution_data_row['name']
              institution_name = institution_data_row['name']
            end
          end

          # double check this lookup by institution name since corresponding institution drupal ids haven't been migrated
          # possibly more institutions in old drupal database than the migrated rails database that we received
          user.institution = Institution.find_by(name: institution_name)
        end
      end

      # TODO: #staticfiles - determine the method to migrate files and the preferred storage method
      # set user avatar from field_data_field_profile_about.field_profile_avatar_fid and the corresponding drupal file

      user.save
      users_drupal_to_rails_ids[row["uid"]] = user.id
    end


    # Migrate communities
    logger.info " - Migrating communities from the Drupal database to the Rails database"

    # Save Drupal <> Rails ids as hash for later lookup
    communities_drupal_to_rails_ids = {}

    results = client.query("SELECT * FROM node WHERE type = 'tapas_project'")
    results.each do |row|
      logger.info " -- #{row["nid"]} #{row["title"]}"

      community = Community.new
      community.title = row["title"]

      # Find Drupal user by row uid and then correspond to Rails user by username
      user = nil
      user_results = client.query("SELECT name FROM users WHERE uid = #{row['uid']}")
      user_results.each do |user_row|
        user = User.find_by(username: user_row["name"])
      end

      # TODO: #users Default to TAPAS user if user is not found as a workaround for making migration dev faster (not remigrating users every time)
      # In the future, this should throw an error
      if user == nil
        user = User.find_by(email: "tapas_rails@tapas.neu.edu")
      end

      community.depositor = user

      # set description from field_data_field_tapas_description.field_tapas_description_value
      description_results = client.query("SELECT field_tapas_description_value FROM field_data_field_tapas_description WHERE entity_id = #{row['nid']}")
      description_results.each do |description_row|
        if description_row['field_tapas_description_value']
          community.description = description_row['field_tapas_description_value']
        end
      end

      # TODO: #users - at the end, migrate the user role data from the Drupal og groups module
      # members
      # editors
      # admins

      # TODO: #staticfiles - determine the method to migrate files and the preferred storage method
      # set thumbnail from field_data_field_tapas_thumbnail.field_tapas_thumbnail_fid and the corresponding drupal file

      community.save
      communities_drupal_to_rails_ids[row["nid"]] = community.id
    end



    # Migrate collections
    logger.info " - Migrating collections from the Drupal database to the Rails database"

    # Save Drupal <> Rails ids as hash for later lookup
    collections_drupal_to_rails_ids = {}

    results = client.query("SELECT * FROM node WHERE type = 'tapas_collection'")
    results.each do |row|
      logger.info " -- #{row["nid"]} #{row["title"]}"

      collection = Collection.new
      collection.title = row["title"]

      # Find Drupal user by row uid and then correspond to Rails user by username
      user = nil
      user_results = client.query("SELECT name FROM users WHERE uid = #{row['uid']}")
      user_results.each do |user_row|
        user = User.find_by(username: user_row["name"])
      end

      # Default to TAPAS user if user is not found as a workaround for making migration dev faster (not remigrating users every time)
      if user == nil
        user = User.find_by(email: "tapas_rails@tapas.neu.edu")
      end
      collection.depositor = user

      # set description from field_data_field_tapas_description.field_tapas_description_value
      description_results = client.query("SELECT field_tapas_description_value FROM field_data_field_tapas_description WHERE entity_id = #{row['nid']}")
      description_results.each do |description_row|
        if description_row['field_tapas_description_value']
          collection.description = description_row['field_tapas_description_value']
        end
      end

      # Collection <> Community relationship is stored in Solr as defined by the Drupal Solr module
      # This relationship is described in Solr via the `sm_og_tapas_c_to_p` parameter
      # SOLR: query via entity_id:
      # http://155.33.22.96:8080/solr/drupal/select?q=entity_id:7&wt=json&indent=true&rows=20
      logger.info " --- rate-limited querying Solr for entity_id #{row['nid']}"
      sleep(10)
      uri = URI("http://155.33.22.96:8080/solr/drupal/select?q=entity_id:#{row['nid']}&wt=json&indent=true&rows=20")
      response = Net::HTTP.get(uri)
      collection_solr_data = JSON.parse(response)
      collection_solr_data['response']['docs'].each do |doc|
        if doc['sm_og_tapas_c_to_p']
          doc['sm_og_tapas_c_to_p'].each do |id|
            collection.community = Community.find(communities_drupal_to_rails_ids[id.gsub('node:', '').to_i])
          end
        end
      end

      # TODO: remove this and throw error--this is currently in for debugging other parts of the application
      # If no community relationship was found, notify
      unless collection.community
        collection.community = Community.first
      end

      # TODO: #staticfiles - determine the method to migrate files and the preferred storage method
      # set thumbnail from field_data_field_tapas_thumbnail.field_tapas_thumbnail_fid and the corresponding drupal file

      collection.save
      collections_drupal_to_rails_ids[row["nid"]] = collection.id
    end


    # Migrate core files
    logger.info " - Migrating core files from the Drupal database to the Rails database"

    # Save Drupal <> Rails ids as hash for later lookup
    core_files_drupal_to_rails_ids = {}

    results = client.query("SELECT * FROM node WHERE type = 'tapas_record'")
    results.each do |row|
      logger.info " -- #{row["nid"]} #{row["title"]}"

      core_file = CoreFile.new
      core_file.title = row["title"]

      # Find Drupal user by row uid and then correspond to Rails user by username
      user = nil
      user_results = client.query("SELECT name FROM users WHERE uid = #{row['uid']}")
      user_results.each do |user_row|
        user = User.find_by(username: user_row["name"])
      end

      # Default to TAPAS user if user is not found as a workaround for making migration dev faster (not remigrating users every time)
      if user == nil
        user = User.find_by(email: "tapas_rails@tapas.neu.edu")
      end

      core_file.depositor = user

      # set description from field_data_field_tapas_description.field_tapas_description_value
      description_results = client.query("SELECT field_tapas_description_value FROM field_data_field_tapas_description WHERE entity_id = #{row['nid']}")
      description_results.each do |description_row|
        if description_row['field_tapas_description_value']
          core_file.description = description_row['field_tapas_description_value']
        end
      end

      # TODO: #staticfiles - determine the method to migrate files and the preferred storage method
      # migrate core_file tei file
      # set canonical_object from field_data_field_tapas_tei_file.field_tapas_tei_file_fid and drupal files

      # set ography_type from field_data_field_tapas_record_ography_type.field_tapas_record_ography_type_value
      ography_type_results = client.query("SELECT field_tapas_record_ography_type_value FROM field_data_field_tapas_record_ography_type WHERE entity_id = #{row['nid']}")
      ography_type_results.each do |ography_type_row|
        if ography_type_row['field_tapas_record_ography_type_value']
          core_file.ography = ography_type_row['field_tapas_record_ography_type_value']
        end
      end

      # TODO: #staticfiles - determine the method to migrate files and the preferred storage method
      # set thumbnail from field_data_field_tapas_thumbnail.field_tapas_thumbnail_fid and the corresponding drupal file

      # CoreFile <> Community relationship = m_field_tapas_project
      # CoreFile <> Collection relationship = sm_og_tapas_r_to_c
      # SOLR: query via entity_id:
      # http://155.33.22.96:8080/solr/drupal/select?q=entity_id:7&wt=json&indent=true&rows=20
      logger.info " --- rate-limited querying Solr for entity_id = #{row['nid']}"
      sleep(10)
      uri = URI("http://155.33.22.96:8080/solr/drupal/select?q=entity_id:#{row['nid']}&wt=json&indent=true&rows=20")
      response = Net::HTTP.get(uri)
      core_file_solr_data = JSON.parse(response)
      core_file_solr_data['response']['docs'].each do |doc|
        if doc['m_field_tapas_project']
          doc['m_field_tapas_project'].each do |id|
            core_file.community = Community.find(communities_drupal_to_rails_ids[id.gsub('node:', '').to_i])
          end
        end
        if doc['sm_og_tapas_r_to_c']
          doc['sm_og_tapas_r_to_c'].each do |id|
            core_file.collections << Collection.find(collections_drupal_to_rails_ids[id.gsub('node:', '').to_i])
          end
        end
      end

      core_file.save
      core_files_drupal_to_rails_ids[row["nid"]] = core_file.id
    end

    # Migrate pages
    logger.info " - Migrating pages from the Drupal database to the Rails database"
    results = client.query("SELECT * FROM node WHERE type = 'tapas_staticpage'")
    results.each do |row|
      logger.info " -- #{row["nid"]} #{row["title"]}"

      page = Page.new
      page.title = row["title"]
      page.slug = page.title.to_s.parameterize

      # TODO: #pages Double check that the string type is what's wanted for this field: https://github.com/ArchimedesDigital/tapas_rails/blame/352f2ff4874395ab94d15c808158b745a84e792b/db/schema.rb#L156
      # In Drupal status = 1 indicates that the node has been published
      if row['status'] == 1
        page.publish = 'true'
      end

      # set page content from field_data_body.body_value
      content_results = client.query("SELECT body_value FROM field_data_body WHERE entity_id = #{row['nid']}")
      content_results.each do |content_row|
        if content_row['body_value']
          page.content = content_row['body_value']
        end
      end

      page.save
    end


    CSV.open("institutions_drupal_to_rails_ids.csv", "wb") {|csv| institutions_drupal_to_rails_ids.to_a.each {|elem| csv << elem} }
    CSV.open("users_drupal_to_rails_ids.csv", "wb") {|csv| users_drupal_to_rails_ids.to_a.each {|elem| csv << elem} }
    CSV.open("communities_drupal_to_rails_ids.csv", "wb") {|csv| communities_drupal_to_rails_ids.to_a.each {|elem| csv << elem} }
    CSV.open("collections_drupal_to_rails_ids.csv", "wb") {|csv| collections_drupal_to_rails_ids.to_a.each {|elem| csv << elem} }
    CSV.open("core_files_drupal_to_rails_ids.csv", "wb") {|csv| core_files_drupal_to_rails_ids.to_a.each {|elem| csv << elem} }

    logger.info "Completed Migration"
    logger.info " - Migrated"
    logger.info " -- #{Institution.count} Institutions"
    logger.info " -- #{User.count} Users"
    logger.info " -- #{Community.count} Communities"
    logger.info " -- #{Collection.count} Collections"
    logger.info " -- #{CoreFile.count} CoreFiles"
    logger.info " -- #{Page.count} Pages"

  end
end
