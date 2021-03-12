require 'net/http'
require 'json'
require 'csv'
require 'optparse'

################################################################################
#
#  migrate_drupal.rake
#  Migrate the TAPAS database from Drupal to Rails
#
#  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#  DISCLAIMER/WARNING: by default this task will drop the data from your local
#    Rails database for several tables; ensure that you have backups and are
#    prepared for this.
#  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
#  - Usage:
#      bin/rake drupal:migrate
#      bin/rake drupal:migrate -- --no-solr --with-user-data
#
#     - with options
#       --no-solr: Skip migrating Solr data (for testing)
#       --with-user-data: Include details about user accounts in your migration
#
#  - Setup:
#      - To get setup to migrate from Drupal to Rails, first ensure your
#        application.yml is configured to connect to your database of choice for
#        receiving the migrated content from Rails.
#      - Next, ensure you have access to a copy of the Drupal database (read-
#        only access is all that's necessary) and configure the
#        DRUPAL_MYSQL_USER, DRUPAL_MYSQL_DB_NAME, and DRUPAL_MYSQL_PASSWORD
#        environment variables for this
#      - Setup the static files from the Drupal application on your local
#        filesystem to be migrated to the application, and set the
#        DRUPAL_STATIC_FILES_PATH variable in your application.yml
#      - Finally, ensure that you're on the NEU VPN for access to the production
#        Solr from the deprecated Drupal site
#
#  - Further notes about the migration tables are available at
#    https://docs.google.com/document/d/1KbB44saOBg7jFyDdMe_6gMT1XombFK6BDufTspZ2N0o/edit?usp=sharing
#    (can be transferred elsewhere in the future as necessary)
#
#
################################################################################

################################################################################
# Dev notes
#
# TODO
# - A future enhancement may be to move solr queries to end of file
#
################################################################################

# Set Rails logger to log to std out while running migration
Rails.logger = Logger.new(STDOUT)
Rails.logger.level = Logger::DEBUG
logger = Rails.logger


desc "Migrate the data from the production Drupal MySQL database to the Rails MySQL database"
namespace :drupal do
  task migrate: [:environment] do
    options = {}
    OptionParser.new do |opts|
      opts.banner = "Usage: rake drupal:migrate [options]"
      opts.on("--with-user-data", "Include details about user accounts in your migration") do
        options[:with_user_data] = true
      end
      opts.on("--no-solr", "Skip migrating Solr data (for testing)") do
        options[:no_solr] = true
      end
      args = opts.order!(ARGV) {}
      opts.parse!(args)
    end
    logger.info options

    logger.info "Migrating drupal database to Rails"
    client = Mysql2::Client.new(:host => "localhost", :username => ENV['DRUPAL_MYSQL_USER'], :database => ENV['DRUPAL_MYSQL_DB_NAME'], :password => ENV['DRUPAL_MYSQL_PASSWORD'])

    # Clear existing DB for migration
    logger.info "Truncating any existing data in institutions, users, communities, collections, core_files, pages, and news_items tables"
    Institution.delete_all
    Community.delete_all
    Collection.delete_all
    CoreFile.delete_all
    User.delete_all
    Page.delete_all
    NewsItem.delete_all


    # Migrate institutions
    logger.info "Migrating institutions from the Drupal database to the Rails database"

    # Save Drupal <> Rails ids as hash for later lookup
    institutions_drupal_to_rails_ids = {}

    # Query all institutions saved as taxonomy terms in Drupal
    results = client.query("SELECT * FROM taxonomy_term_data WHERE vid = 2")
    institutions_drupal_count = results.count
    results.each do |row|
      logger.info " -- institution #{row["tid"]} #{row["name"]}"

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

      institution.save!
      institutions_drupal_to_rails_ids[row["tid"]] = institution.id
    end


    # Migrate users
    logger.info "Migrating users from the Drupal database to the Rails database"

    # Save Drupal <> Rails ids as hash for later lookup
    users_drupal_to_rails_ids = {}

    results = client.query("SELECT * FROM users WHERE uid != 0")
    users_drupal_count = results.count
    results.each do |row|
      logger.info " -- user #{row["uid"]} #{row["name"]}"
      # create user with migration passwords
      user = User.new

      user.username = row["name"]
      if row["mail"] && row["mail"].strip.length != 0
        user.email = row["mail"]
      else
        # Not all users from Drupal have an email
        user.email = "update#{row["uid"]}@example.edu"
      end
      user.password = "migration"
      user.password_confirmation = "migration"

      # Don't send an email to the user on migration
      user.skip_confirmation!

      if options[:with_user_data]
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
      end

      user.save!
      users_drupal_to_rails_ids[row["uid"]] = user.id
    end


    # Migrate communities
    logger.info "Migrating communities from the Drupal database to the Rails database"

    # Save Drupal <> Rails ids as hash for later lookup
    communities_drupal_to_rails_ids = {}

    results = client.query("SELECT * FROM node WHERE type = 'tapas_project'")
    communities_drupal_count = results.count
    results.each do |row|
      logger.info " -- community #{row["nid"]} #{row["title"]}"

      community = Community.new
      community.title = row["title"]

      # Find Drupal user by row uid
      community.depositor = User.find(users_drupal_to_rails_ids[row['uid']])

      # set description from field_data_field_tapas_description.field_tapas_description_value
      description_results = client.query("SELECT field_tapas_description_value FROM field_data_field_tapas_description WHERE entity_id = #{row['nid']}")
      description_results.each do |description_row|
        if description_row['field_tapas_description_value']
          community.description = description_row['field_tapas_description_value']
        end
      end

      # Set user roles from og_users_roles.rid
      user_role_results = client.query("SELECT uid, rid FROM og_users_roles WHERE gid = #{row['nid']}")
      community_user_ids = []
      user_role_results.each do |user_role_row|
        if user_role_row['uid'] && user_role_row['rid']
          community_member = CommunityMember.new
          community_member.user = User.find(users_drupal_to_rails_ids[user_role_row["uid"]])

          # enforce uniqueness for user per project
          unless community_user_ids.include? users_drupal_to_rails_ids[user_role_row["uid"]]

            if user_role_row['rid'] == 9
              # user is admin
              community_member.member_type = 'admin'
              community.community_members << community_member

            elsif user_role_row['rid'] == 17
              # user is editor
              community_member.member_type = 'editor'
              community.community_members << community_member

            elsif user_role_row['rid'] == 8
              # user is member
              community_member.member_type = 'member'
              community.community_members << community_member

            else
              logger.fatal " -- Error: user role unrecognized for Community user_id: #{user_role_row['uid']} role_id: #{user_role_row["rid"]}"
            end

            community_user_ids.push(users_drupal_to_rails_ids[user_role_row["uid"]])
          end

        end
      end

      # set thumbnail from field_data_field_tapas_thumbnail.field_tapas_thumbnail_fid and the corresponding drupal file
      file_results = client.query("SELECT field_tapas_thumbnail_fid FROM field_data_field_tapas_thumbnail WHERE entity_id = #{row['nid']}")
      file_results.each do |file_row|
        if file_row['field_tapas_thumbnail_fid']
          file_managed_results = client.query("SELECT uri FROM file_managed WHERE fid = #{file_row['field_tapas_thumbnail_fid']}")
          file_managed_results.each do |file_managed_row|
            if file_managed_row['uri']
              logger.info " -- -- uploading #{file_managed_row["uri"]} to s3"
              fname = file_managed_row["uri"].sub! "public://", ""

              if File.exist?(File.join(ENV['DRUPAL_STATIC_FILES_PATH'], fname))
                blob = ActiveStorage::Blob.create_after_upload!(
                  io: File.open(File.join(ENV['DRUPAL_STATIC_FILES_PATH'], fname)),
                  filename: fname,
                  content_type: Rack::Mime.mime_type(File.extname(fname))
                )
                blob.analyze
                community.save
                ActiveStorage::Attachment.create(
                  name: 'thumbnail',
                  record_type: 'Community',
                  record_id: community.id,
                  blob_id: blob.id
                )
              else
                logger.error " -- Error: File does not exist in Drupal static files #{file_managed_row["uri"]} to s3"
              end
            end
          end
        end
      end

      community.save!
      communities_drupal_to_rails_ids[row["nid"]] = community.id
    end



    # Migrate collections
    logger.info "Migrating collections from the Drupal database to the Rails database"

    # Save Drupal <> Rails ids as hash for later lookup
    collections_drupal_to_rails_ids = {}

    results = client.query("SELECT * FROM node WHERE type = 'tapas_collection'")
    collections_drupal_count = results.count
    results.each do |row|
      logger.info " -- collection #{row["nid"]} #{row["title"]}"

      collection = Collection.new
      collection.title = row["title"]

      # Find Drupal user by row uid
      collection.depositor = User.find(users_drupal_to_rails_ids[row['uid']])

      # set description from field_data_field_tapas_description.field_tapas_description_value
      description_results = client.query("SELECT field_tapas_description_value FROM field_data_field_tapas_description WHERE entity_id = #{row['nid']}")
      description_results.each do |description_row|
        if description_row['field_tapas_description_value']
          collection.description = description_row['field_tapas_description_value']
        end
      end

      unless collection.description && collection.description.strip.length
        collection.description = "Default description that should be updated."
      end

      # Collection <> Community relationship is stored in Solr as defined by the Drupal Solr module
      # This relationship is described in Solr via the `sm_og_tapas_c_to_p` parameter
      # SOLR: query via entity_id:
      # http://155.33.22.96:8080/solr/drupal/select?q=entity_id:7&wt=json&indent=true&rows=20
      if  options[:no_solr]
        collection.community = Community.first
      else
        logger.info " -- -- rate-limited querying Solr for entity_id #{row['nid']}"
        sleep(10)
        uri = URI("http://155.33.22.96:8080/solr/drupal/select?q=entity_id:#{row['nid']}&wt=json&indent=true&rows=20")
        response = Net::HTTP.get(uri)
        collection_solr_data = JSON.parse(response)
        collection_solr_data['response']['docs'].each do |doc|
          if doc['sm_og_tapas_c_to_p']
            doc['sm_og_tapas_c_to_p'].each do |id|
              begin
                collection.community = Community.find(communities_drupal_to_rails_ids[id.gsub('node:', '').to_i])
              rescue ActiveRecord::RecordNotFound => e
                print e
              end
            end
          end
        end
      end

      collection.save!
      if collection.id
        # set thumbnail from field_data_field_tapas_thumbnail.field_tapas_thumbnail_fid and the corresponding drupal file
        file_results = client.query("SELECT field_tapas_thumbnail_fid FROM field_data_field_tapas_thumbnail WHERE entity_id = #{row['nid']}")
        file_results.each do |file_row|
          if file_row['field_tapas_thumbnail_fid']
            file_managed_results = client.query("SELECT uri FROM file_managed WHERE fid = #{file_row['field_tapas_thumbnail_fid']}")
            file_managed_results.each do |file_managed_row|
              if file_managed_row['uri']
                logger.info " -- -- uploading #{file_managed_row["uri"]} to s3"
                fname = file_managed_row["uri"].sub! "public://", ""
                if File.exist?(File.join(ENV['DRUPAL_STATIC_FILES_PATH'], fname))
                  blob = ActiveStorage::Blob.create_after_upload!(
                    io: File.open(File.join(ENV['DRUPAL_STATIC_FILES_PATH'], fname)),
                    filename: fname,
                    content_type: Rack::Mime.mime_type(File.extname(fname))
                  )
                  blob.analyze
                  ActiveStorage::Attachment.create(
                    name: 'thumbnails',
                    record_type: 'Collection',
                    record_id: collection.id,
                    blob_id: blob.id
                  )
                else
                  logger.error " -- Error: File does not exist in Drupal static files #{file_managed_row["uri"]} to s3"
                end
              end
            end
          end
        end
      end

      collection.save!
      collections_drupal_to_rails_ids[row["nid"]] = collection.id
    end


    # Migrate core files
    logger.info "Migrating core files from the Drupal database to the Rails database"

    # Save Drupal <> Rails ids as hash for later lookup
    core_files_drupal_to_rails_ids = {}

    results = client.query("SELECT * FROM node WHERE type = 'tapas_record'")
    core_files_drupal_count = results.count
    results.each do |row|
      logger.info " -- core file #{row["nid"]} #{row["title"]}"

      core_file = CoreFile.new
      core_file.title = row["title"]

      # Find Drupal user by row uid
      core_file.depositor = User.find(users_drupal_to_rails_ids[row['uid']])

      # set description from field_data_field_tapas_description.field_tapas_description_value
      description_results = client.query("SELECT field_tapas_description_value FROM field_data_field_tapas_description WHERE entity_id = #{row['nid']}")
      description_results.each do |description_row|
        if description_row['field_tapas_description_value']
          core_file.description = description_row['field_tapas_description_value']
        end
      end

      # migrate core_file tei file
      # set canonical_object from field_data_field_tapas_tei_file.field_tapas_tei_file_fid and drupal files
      file_results = client.query("SELECT field_tapas_tei_file_fid FROM field_data_field_tapas_tei_file WHERE entity_id = #{row['nid']}")
      file_results.each do |file_row|
        if file_row['field_tapas_tei_file_fid']
          file_managed_results = client.query("SELECT uri FROM file_managed WHERE fid = #{file_row['field_tapas_tei_file_fid']}")
          file_managed_results.each do |file_managed_row|
            if file_managed_row['uri']
              logger.info " -- -- uploading #{file_managed_row["uri"]} to s3"
              fname = file_managed_row["uri"].sub! "public://", ""

              if File.exist?(File.join(ENV['DRUPAL_STATIC_FILES_PATH'], fname))
                blob = ActiveStorage::Blob.create_after_upload!(
                  io: File.open(File.join(ENV['DRUPAL_STATIC_FILES_PATH'], fname)),
                  filename: fname,
                  content_type: Rack::Mime.mime_type(File.extname(fname))
                )
                blob.analyze
                core_file.save
                ActiveStorage::Attachment.create(
                  name: 'canonical_object',
                  record_type: 'CoreFile',
                  record_id: core_file.id,
                  blob_id: blob.id
                )
              else
                logger.error " -- Error: File does not exist in Drupal static files #{file_managed_row["uri"]} to s3"
              end
            end
          end
        end
      end

      # set ography_type from field_data_field_tapas_record_ography_type.field_tapas_record_ography_type_value
      ography_type_results = client.query("SELECT field_tapas_record_ography_type_value FROM field_data_field_tapas_record_ography_type WHERE entity_id = #{row['nid']}")
      ography_type_results.each do |ography_type_row|
        if ography_type_row['field_tapas_record_ography_type_value']
          core_file.ography = ography_type_row['field_tapas_record_ography_type_value']
        end
      end

      # set thumbnail from field_data_field_tapas_thumbnail.field_tapas_thumbnail_fid and the corresponding drupal file
      file_results = client.query("SELECT field_tapas_thumbnail_fid FROM field_data_field_tapas_thumbnail WHERE entity_id = #{row['nid']}")
      file_results.each do |file_row|
        if file_row['field_tapas_thumbnail_fid']
          file_managed_results = client.query("SELECT uri FROM file_managed WHERE fid = #{file_row['field_tapas_thumbnail_fid']}")
          file_managed_results.each do |file_managed_row|
            if file_managed_row['uri']
              logger.info " -- -- uploading #{file_managed_row["uri"]} to s3"
              fname = file_managed_row["uri"].sub! "public://", ""

              blob = ActiveStorage::Blob.create_after_upload!(
                io: File.open(File.join(ENV['DRUPAL_STATIC_FILES_PATH'], fname)),
                filename: fname,
                content_type: Rack::Mime.mime_type(File.extname(fname))
              )
              blob.analyze
              ActiveStorage::Attachment.create(
                name: 'thumbnails',
                record_type: 'CoreFile',
                record_id: core_file.id,
                blob_id: blob.id
              )
            end
          end
        end
      end

      # CoreFile <> Community relationship = m_field_tapas_project
      # CoreFile <> Collection relationship = sm_og_tapas_r_to_c
      # SOLR: query via entity_id:
      # http://155.33.22.96:8080/solr/drupal/select?q=entity_id:7&wt=json&indent=true&rows=20
      unless options[:no_solr]
        logger.info " -- -- rate-limited querying Solr for entity_id = #{row['nid']}"
        sleep(10)
        uri = URI("http://155.33.22.96:8080/solr/drupal/select?q=entity_id:#{row['nid']}&wt=json&indent=true&rows=20")
        response = Net::HTTP.get(uri)
        core_file_solr_data = JSON.parse(response)
        core_file_solr_data['response']['docs'].each do |doc|
          if doc['m_field_tapas_project']
            doc['m_field_tapas_project'].each do |id|
              begin
                core_file.community = Community.find(communities_drupal_to_rails_ids[id.gsub('node:', '').to_i])
              rescue ActiveRecord::RecordNotFound => e
                logger.error e
              end
            end
          end
          if doc['sm_og_tapas_r_to_c']
            doc['sm_og_tapas_r_to_c'].each do |id|
              begin
                core_file.collections << Collection.find(collections_drupal_to_rails_ids[id.gsub('node:', '').to_i])
              rescue ActiveRecord::RecordNotFound => e
                logger.error e
              end
            end
          end
        end
      end

      core_file.save!
      core_files_drupal_to_rails_ids[row["nid"]] = core_file.id
    end

    # Migrate pages
    logger.info "Migrating pages from the Drupal database to the Rails database"

    # Save Drupal <> Rails ids as hash for later lookup
    pages_drupal_to_rails_ids = {}

    results = client.query("SELECT * FROM node WHERE type = 'tapas_staticpage'")
    pages_drupal_count = results.count
    results.each do |row|
      logger.info " -- page #{row["nid"]} #{row["title"]}"

      page = Page.new
      page.title = row["title"]
      page.slug = page.title.to_s.parameterize

      # In Drupal status = 1 indicates that the node has been published
      if row['status'] == 1
        page.publish = 1
      end

      # set page content from field_data_body.body_value
      content_results = client.query("SELECT body_value FROM field_data_body WHERE entity_id = #{row['nid']}")
      content_results.each do |content_row|
        if content_row['body_value']
          page.content = content_row['body_value']
        end
      end

      unless page.content && page.content.strip.length
        page.content = "Default content that should be updated."
      end

      page.save!
      pages_drupal_to_rails_ids[row["nid"]] = page.id
    end

    # Migrate news items
    logger.info "Migrating news items from the Drupal database to the Rails database"

    # Save Drupal <> Rails ids as hash for later lookup
    news_items_drupal_to_rails_ids = {}

    results = client.query("SELECT * FROM node WHERE type = 'tapas_newsitem'")
    news_items_drupal_count = results.count
    results.each do |row|
      logger.info " -- news item #{row["nid"]} #{row["title"]}"

      news_item = NewsItem.new
      news_item.title = row["title"]
      news_item.slug = news_item.title.to_s.parameterize

      # some news items may have the same title, so check and verify slug is unique
      if NewsItem.find_by(slug: news_item.slug)
        news_item.slug = "#{news_item.title.to_s.parameterize}-#{row["nid"]}"
      end

      # In Drupal status = 1 indicates that the node has been published
      if row['status'] == 1
        news_item.publish = 1
      end

      # set page content from field_data_body.body_value
      content_results = client.query("SELECT body_value FROM field_data_body WHERE entity_id = #{row['nid']}")
      content_results.each do |content_row|
        if content_row['body_value']
          news_item.content = content_row['body_value']
        end
      end

      unless news_item.content && news_item.content.strip.length
        news_item.content = "Default content that should be updated."
      end

      # Find Drupal user by row uid
      news_item.author = User.find(users_drupal_to_rails_ids[row['uid']])

      news_item.save!
      news_items_drupal_to_rails_ids[row["nid"]] = news_item.id
    end


    # Add header to each file as drupal_id,rails_id
    CSV.open("institutions_drupal_to_rails_ids.csv", "wb") {|csv| institutions_drupal_to_rails_ids.to_a.each {|elem| csv << elem} }
    CSV.open("users_drupal_to_rails_ids.csv", "wb") {|csv| users_drupal_to_rails_ids.to_a.each {|elem| csv << elem} }
    CSV.open("communities_drupal_to_rails_ids.csv", "wb") {|csv| communities_drupal_to_rails_ids.to_a.each {|elem| csv << elem} }
    CSV.open("collections_drupal_to_rails_ids.csv", "wb") {|csv| collections_drupal_to_rails_ids.to_a.each {|elem| csv << elem} }
    CSV.open("core_files_drupal_to_rails_ids.csv", "wb") {|csv| core_files_drupal_to_rails_ids.to_a.each {|elem| csv << elem} }
    CSV.open("pages_drupal_to_rails_ids.csv", "wb") {|csv| pages_drupal_to_rails_ids.to_a.each {|elem| csv << elem} }
    CSV.open("news_items_drupal_to_rails_ids.csv", "wb") {|csv| news_items_drupal_to_rails_ids.to_a.each {|elem| csv << elem} }

    logger.info "-" * 40
    logger.info "Completed Migration:"
    logger.info " -- Institutions"
    logger.info " -- -- #{institutions_drupal_count} from Drupal"
    logger.info " -- -- #{Institution.count} in Rails"
    logger.info " -- Users"
    logger.info " -- -- #{users_drupal_count} from Drupal"
    logger.info " -- -- #{User.count} in Rails"
    logger.info " -- Communities"
    logger.info " -- -- #{communities_drupal_count} from Drupal"
    logger.info " -- -- #{Community.count} in Rails"
    logger.info " -- Collections"
    logger.info " -- -- #{collections_drupal_count} from Drupal"
    logger.info " -- -- #{Collection.count} in Rails"
    logger.info " -- CoreFiles"
    logger.info " -- -- #{core_files_drupal_count} from Drupal"
    logger.info " -- -- #{CoreFile.count} in Rails"
    logger.info " -- Pages"
    logger.info " -- -- #{pages_drupal_count} from Drupal"
    logger.info " -- -- #{Page.count} in Rails"
    logger.info " -- NewsItems"
    logger.info " -- -- #{news_items_drupal_count} from Drupal"
    logger.info " -- -- #{NewsItem.count} in Rails"
    logger.info "-" * 40
  end
end
