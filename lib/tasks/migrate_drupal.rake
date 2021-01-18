# Notes about the migration tables at https://docs.google.com/document/d/1KbB44saOBg7jFyDdMe_6gMT1XombFK6BDufTspZ2N0o/edit?usp=sharing

desc "Migrate the data from the production Drupal MySQL database to the Rails MySQL database"
namespace :drupal do
  task migrate: [:environment] do
    puts "Migrating drupal database to Rails"
    client = Mysql2::Client.new(:host => "localhost", :username => ENV['DRUPAL_MYSQL_USER'], :database => ENV['DRUPAL_MYSQL_DB_NAME'], :password => ENV['DRUPAL_MYSQL_PASSWORD'])

    # Clear existing DB for migration
    puts " - Truncating any existing data in users, communities, collections, and core_files tables"
    Community.delete_all
    Collection.delete_all
    CoreFile.delete_all
    User.delete_all

    # Migrate users
    puts " - Migrating users from the Drupal database to the Rails database"
    results = client.query("SELECT * FROM users WHERE uid != 0")

    results.each do |row|
      puts " -- #{row["uid"]} #{row["name"]}"
      # create user with migration passwords
      user = User.create(username: row["name"], email: row["mail"], password: "migration", password_confirmation: "migration")

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

      # TODO ask Candace in order to determine the method to migrate files and the preferred storage method
      # set user avatar from field_data_field_profile_about.field_profile_avatar_fid and the corresponding drupal file

      user.save
    end


    # Migrate communities
    puts " - Migrating communities from the Drupal database to the Rails database"
    results = client.query("SELECT * FROM node WHERE type = 'tapas_project'")

    results.each do |row|
      puts " -- #{row["nid"]} #{row["title"]}"

      community = Community.new
      community.title = row["title"]

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

      community.depositor = user

      # set description from field_data_field_tapas_description.field_tapas_description_value
      description_results = client.query("SELECT field_tapas_description_value FROM field_data_field_tapas_description WHERE entity_id = #{row['nid']}")
      description_results.each do |description_row|
        if description_row['field_tapas_description_value']
          community.description = description_row['field_tapas_description_value']
        end
      end


      # TODO: Ask Candace about this, because I'm unsure where user <> community role relations exist in Drupal
      # members
      # editors
      # admins

      # TODO ask Candace in order to determine the method to migrate files and the preferred storage method
      # set thumbnail from field_data_field_tapas_thumbnail.field_tapas_thumbnail_fid and the corresponding drupal file

      community.save
    end



    # Migrate collections
    puts " - Migrating collections from the Drupal database to the Rails database"
    results = client.query("SELECT * FROM node WHERE type = 'tapas_collection'")

    results.each do |row|
      puts " -- #{row["nid"]} #{row["title"]}"


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

      # TODO: ask Candace about Collection community relationship because it's unclear where this resides in the original Drupal database
      # For testing, grab the first community
      collection.community = Community.first

      # TODO ask Candace in order to determine the method to migrate files and the preferred storage method
      # set thumbnail from field_data_field_tapas_thumbnail.field_tapas_thumbnail_fid and the corresponding drupal file

      collection.save
    end



    # Migrate core files
    puts " - Migrating core files from the Drupal database to the Rails database"
    results = client.query("SELECT * FROM node WHERE type = 'tapas_record'")

    results.each do |row|
      puts " -- #{row["nid"]} #{row["title"]}"

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

      # core_file tei file
      # set canonical_object from field_data_field_tapas_tei_file.field_tapas_tei_file_fid and drupal files


      # TODO ask Candace in order to determine if old method of associating core files and communities in Drupal is needed in Rails
      # core files <> communities
      # set core_files communities relationship from field_data_field_tapas_project.field_tapas_project_target_id
      # community_results = client.query("SELECT field_tapas_project_target_id FROM field_data_field_tapas_project WHERE entity_id = #{row['nid']}")
      # community_results.each do |community_row|
      #   if community_row['field_tapas_project_target_id']
      #     # find the project node in Drupal
      #     community_node_results = client.query("SELECT title FROM node WHERE nid = #{community_row['field_tapas_project_target_id']}")
      #     community_node_results.each do |community_node_row|
      #       # find the corresponding community in Rails
      #     end
      #   end
      # end


      # core files <> collections
      # core_file.collections = Collection.first


      # TODO: clarify with Candance how she wants the ography type stored in the data model
      # ography type
      # set ography_type from field_data_field_tapas_record_ography_type.field_tapas_record_ography_type_value
      # ography_type_results = client.query("SELECT field_tapas_record_ography_type_value FROM field_data_field_tapas_record_ography_type WHERE entity_id = #{row['nid']}")
      # ography_type_results.each do |orgraphy_type_row|
      #   if orgraphy_type_row['field_tapas_record_ography_type_value']
      #     core_file.ography = orgraphy_type_row['field_tapas_record_ography_type_value']
      #   end
      # end


      # TODO ask Candace in order to determine the method to migrate files and the preferred storage method
      # set thumbnail from field_data_field_tapas_thumbnail.field_tapas_thumbnail_fid and the corresponding drupal file


      core_file.save
    end

  end
end
