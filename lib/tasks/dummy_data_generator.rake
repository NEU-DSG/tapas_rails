namespace :dummy_data_generator do
  require 'net/http'
  require 'open-uri'
  require 'dummy_data'

  IMAGE_BASE_URL = ENV.fetch("IMAGE_BASE_URL", nil)
  RAW_TEI_URL = ENV.fetch("RAW_TEI_URL", nil)

  def fake
    DummyData.user_input
  end

  def record_image(record, image_name=nil)
    url = IMAGE_BASE_URL
    image_data = URI.open(url)
    image_name ||= "#{record.class}_#{record.__id__}"
    depositor_id = record.is_a?(User) ? record.id : record.depositor_id

    record_assoc_image = ImageFile.create(
      title: image_name,
      depositor_id: depositor_id,
      imageable_type: record.class.name,
      imageable_id: record.id,
      file_format: image_data&.content_type,
      image_url: url
    )

    record_assoc_image.save

    record.image_file.attach(io: image_data, filename: record_assoc_image.title, content_type: record_assoc_image.file_format)

    puts "Image file attached for core file #{record.__id__}."
  end

  # this simulates the user uploading a TEI file during the process of creating
  # a core file
  def create_tei(record)
    url = RAW_TEI_URL
    tei_data = URI.open(url)
    tei_name ||= "#{record.__id__}-#{record.title}-TEI"

    assoc_tei = TEIFile.create(
      core_file_id: record.id,
      name: tei_name,
      url: url,
      data: tei_data
    )

    assoc_tei.save

    attach_tei(assoc_tei)
  end

  # this should occur when a core file is created and saved with a tei file
  def attach_tei(tei_file)
    record = tei_file.core_file
    io = tei_file.process_data

    # try this
    # record.create_tei_file(file: File.open("#{tei_file.url}"))

    record.tei_file.attach(
      io: io,
      filename: tei_file.name,
      content_type: tei_file.data.class
    )

    puts "TEI file attached for core file #{record.__id__}."
  end

  def create_project_members
    Project.all.each do |project|
      non_admin_ids = User.all.select { |u| u.admin_at.nil? }.map(&:id)

      # contributors
      # has a TAPAS account and either creates or contributes to a TAPAS project
      5.times do
        user_id = (non_admin_ids - ProjectMember.all.map(&:user_id)).sample

        ProjectMember.create(project_id: project.id,
                             user_id: user_id,
                             role: 'contributor'
        )
      end

      # collaborator
      # has editorial access to a TAPAS project but is not the owner
      3.times do
        user_id = (non_admin_ids - ProjectMember.all.map(&:user_id)).sample

        ProjectMember.create(project_id: project.id,
                             user_id: user_id,
                             role: 'collaborator'
        )
      end

      # project owners
      # has created the project in question and has responsibility for it
      1.times do
        user_id = (non_admin_ids - ProjectMember.all.map(&:user_id)).sample

        ProjectMember.create(project_id: project.id,
                             user_id: user_id,
                             role: 'owner'
        )
      end
    end
  end

  def create_collections
    Project.all.each do |project|
      project_users = project.members.values.flatten.shuffle

      3.times do
        Collection.create(title: fake[:food],
                                 description: fake[:description],
                                 depositor_id: project_users.sample&.id,
                                 project_id: project.id,
                                 is_public: true
        )
      end

      2.times do
        Collection.create(title: fake[:food],
                                  description: fake[:description],
                                  depositor_id: project_users.sample&.id,
                                  project_id: project.id,
                                  is_public: false
        )
      end
    end
  end

  def create_core_files
    Collection.all.each do |collection|
      project = collection.project
      collection_users = project.members.values.flatten.shuffle
      visibility = collection.is_public
      ography_types = CoreFile.all_ography_types

      50.times do
        core_file = CoreFile.create(title: fake[:book_title],
                        description: fake[:book_genre],
                        depositor_id: collection_users.sample&.id,
                        collections: [collection].compact,
                        is_public: [visibility, !visibility].sample
        )

        if core_file.id.nil? || !core_file.valid?
          puts 'Create Core Files task failed.'
        else
          puts "Core file #{core_file.id} created within Collection #{collection.id}"
        end

        if core_file.id % 5 == 0
          record_image(core_file)
        else
          core_file.update(
            tei_authors: [
              fake[:animal] + ' ' + fake[:horse],
              fake[:animal] + ' ' + fake[:dog_breed]
            ],
            tei_contributors: [
              fake[:cop_comedy],
              fake[:animation],
              fake[:college]
            ]
          )

          create_tei(core_file)
        end
      end

      5.times do
        core_file = CoreFile.create(title: fake[:book_title],
                        description: fake[:book_genre],
                        depositor_id: collection_users.sample&.id,
                        collections: [collection].compact,
                        is_public: visibility,
                        ography_type: ography_types.sample
        )

        record_image(core_file)
      end
    end
  end

  desc "creates projects"
  task :projects => :environment do
    22.times do
      Project.create(title: fake[:jargon],
                     description: fake[:bio],
                     depositor_id: User.all.sample.id,
                     institution: fake[:uni]
      )
    end

    3.times do
      Project.create(title: fake[:jargon],
                     description: fake[:bio],
                     depositor_id: User.all.where(admin_at: nil).sample.id,
                     is_public: false,
                     institution: fake[:uni]
      )
    end

    puts Project.count == 25 ? '25 Projects created.' : '"Create Projects" task failed.'
  end

  desc 'creates project members'
  task :project_members => :environment do
    if Project.any?
      create_project_members
    else
      puts 'Create projects task failed.'
    end
  end

  desc 'creates collections'
  task :collections => :environment do
    if Project.any?
      create_collections
    else
      puts 'Create Project task failed.'
    end
  end

  desc 'create -ography types'
  # TODO: this isn't the best term for what this table will capture, i.e., an odd_file isn't an ography, but is a distinct form of a tei_file that might need special handling.
  task :ography_types => :environment do

    ography_table_import = "mysql -u #{ENV['MYSQL_USER']} -p #{ENV['MYSQL_PASSWORD']} tapas_rails < db/data/ography_types_dump.sql"

    system(ography_table_import)
  end

  desc 'creates core files'
  task :core_files => :environment do
    if Collection.any?
      create_core_files
    else
      puts '"Create Collections" task failed. Cannot create core files.'
    end
  end

  desc "creates admin user"
  task :admin_user => :environment do
    # TODO: add error handling for when the .env file isn't accessible in the filesystem
    email = JSON.parse(ENV['APP_ADMINS'])[0]
    password = ENV.fetch('DUMMY_ADMIN_PASSWORD')
    user = User.create(name: 'Admin',
                email: email,
                bio: fake[:bio],
                password: password,
                admin_at: Time.now
    )

    puts "Admin user #{user.id} has been created." unless user.nil?
  end

  desc "creates debug non-admin user"
  task :debug_non_admin_user => :environment do
    email = ENV.fetch('DUMMY_DEBUG_EMAIL')
    password = ENV.fetch('DUMMY_DEBUG_PASSWORD')
    user = User.create(name: 'Debug',
                email: email,
                bio: fake[:bio],
                password: password
    )

    puts "Debug non-admin user #{user.id} has been created." unless user.nil?
  end

  desc "creates non-admin users"
  task :non_admin_users => :environment do
    275.times do
      user = User.create(name: fake[:person_name],
                  email: fake[:email],
                  bio: fake[:bio],
                  password: fake[:password]
      )

      puts "Non-admin user #{user.id} has been created." unless user.nil?
    end
  end

  desc 'generate all dummy data'
  task :run_all => :environment do
    Rake::Task['dummy_data_generator:user_records'].invoke
    Rake::Task['dummy_data_generator:non_user_records'].invoke
  end

  desc 'create user table records'
  task :create_user_records => :environment do
    puts 'Creating admin user...'
    Rake::Task['dummy_data_generator:admin_user'].invoke

    puts 'Creating debug user...'
    Rake::Task['dummy_data_generator:debug_non_admin_user'].invoke

    puts 'Creating non-admin users...'
    Rake::Task['dummy_data_generator:non_admin_users'].invoke
  end

  desc 'create all non-user table records'
  task :create_non_user_records => :environment do
    puts 'Creating projects...'
    Rake::Task['dummy_data_generator:projects'].invoke

    puts 'Creating project members...'
    Rake::Task['dummy_data_generator:project_members'].invoke

    puts 'Creating collections...'
    Rake::Task['dummy_data_generator:collections'].invoke

    if [User, Project, ProjectMember, Collection].map(&:any?).include?(false)
      puts 'Deleting Solr index'
      Rake::Task['dummy_data_generator:delete_indexed'].invoke

      puts 'Recreating database'
      Rake::Task['db:drop'].invoke
      Rake::Task['db:create'].invoke
      Rake::Task['db:migrate'].invoke
      Rake::Task['dummy_data_generator:all_users'].invoke
    else
      puts 'Creating core files'
      Rake::Task['dummy_data_generator:core_files'].invoke
    end
  end

  desc 'delete all non-user table records'
  task :delete_non_user_records => :environment do
    [
      Project,
      ProjectMember,
      Collection,
      CoreFile,
      ImageFile,
      TEIFile
    ].map(&:delete_all)
  end

  desc 'drop and recreate db'
  task :drop_rebuild_db => :environment do
    puts 'Recreating database'
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
  end

  desc 'deletes all records from solr index'
  task :delete_indexed => :environment do
    SolrHelpers.delete_all_indexed_records
  end
end

# generate user avatars, collection and project thumbnails, and core file images
# file = URI.open('https://placekitten.com/300/300')
# user.image_file.attach(io: file, filename: 'test_image.png', content_type: 'image/png')
#
# # Attach a user avatar
# user.create_image_file(file: File.open('/path/to/avatar.png'))
#
# # Access the attached avatar
# user.avatar_file # Equivalent to user.image_file.file
#
# # Check if an avatar is attached
# user.avatar_file.attached?
#
# # Attach a project thumbnail
# project.create_image_file(file: File.open('/path/to/thumbnail.png'))
#
# # Access the attached thumbnail
# project.thumbnail_file # Equivalent to project.image_file.file
#
# # Check if a thumbnail is attached
# project.thumbnail_file.attached?
