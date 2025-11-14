namespace :dummy_data_generator do
  require 'faker'
  require 'net/http'
  require 'open-uri'

  # Helper method to check if Resque workers are running
  def check_resque_workers
    worker_count = Resque.workers.size

    if worker_count == 0
      puts "\n" + "=" * 80
      puts "WARNING: No Resque workers detected!"
      puts "=" * 80
      puts ""
      puts "File uploads require a running Resque worker to process ActiveStorage jobs."
      puts "Without a worker, file attachments will be queued but never processed."
      puts ""
      puts "To start a Resque worker, run this command in a separate terminal:"
      puts "  QUEUE=* bundle exec rake resque:work"
      puts ""
      puts "=" * 80
      puts ""

      print "Continue anyway? (y/N): "
      response = STDIN.gets.chomp.downcase
      unless response == 'y' || response == 'yes'
        puts "Aborted. Please start a Resque worker and try again."
        exit 1
      end
    else
      puts "✓ Resque workers running: #{worker_count}"
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

  IMAGE_BASE_URL = ENV.fetch("IMAGE_BASE_URL", nil)
  RAW_TEI_URL = ENV.fetch("RAW_TEI_URL", nil)

  def record_image(record, image_name=nil)
    url = "#{IMAGE_BASE_URL}"
    image_data = URI.open(url)
    image_name ||= "#{record.class}_#{record.__id__}"
    depositor_id = record.is_a?(User) ? record.id : record.depositor_id

    record_assoc_image_file = ImageFile.create(
      title: image_name,
      depositor_id: depositor_id,
      imageable_type: record.class.name,
      imageable_id: record.id,
      file_format: image_data&.content_type,
      image_url: url
    )

    # Attach the file to the ImageFile model (not directly to the record)
    record_assoc_image_file.file.attach(io: image_data, filename: record_assoc_image_file.title, content_type: record_assoc_image_file.file_format)
    record_assoc_image_file.save

    puts "Image file attached for #{record.class} #{record.id}"
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

      puts "#{project.members.values.flatten.count} project members created for #{project.__id__}: #{project.title}."
    end
  end

  def create_collections
    Project.all.each do |project|
      project_users = project.members.values.flatten.shuffle

      2.times do
        public = Collection.create(title: Faker::Food.dish,
                                   description: Faker::GreekPhilosophers.quote,
                                   depositor_id: project_users.sample&.id,
                                   project_id: project.id,
                                   is_public: true
        )

        puts "Public collection #{public.id}: #{public.title} created for Project #{project.id}."
      end

      1.times do
        private = Collection.create(title: Faker::Food.dish,
                                    description: Faker::GreekPhilosophers.quote,
                                    depositor_id: project_users.sample&.id,
                                    project_id: project.id,
                                    is_public: false
        )

        puts "Private collection #{private.id}: #{private.title} created for Project #{project.id}."
      end
    end
  end

  def create_core_files
    Collection.all.each do |collection|
      project = collection.project
      collection_users = project.members.values.flatten.shuffle
      visibility = collection.is_public
      ography_types = CoreFile.all_ography_types
      record_count_range = 1..7

      # Create regular TEI content files
      record_count_range.to_a.sample.times do |i|
        core_file = CoreFile.new(title: Faker::Book.title,
                        description: Faker::Book.genre,
                        depositor_id: collection_users.sample&.id,
                        collections: [collection].compact,
                        is_public: [visibility, !visibility].sample,
                        tei_authors: Faker::Creature.name
        )

        # Attach TEI file (required for non-ography files)
        attach_tei_file(core_file)

        if core_file.save
          puts "Core file #{core_file.id} created within Collection #{collection.id}"
        else
          puts "Create Core Files task failed: #{core_file.errors.full_messages.join(', ')}"
        end
      end

      record_count_range.to_a.sample.times do
        core_file = CoreFile.new(title: Faker::Book.title,
                                 description: Faker::Book.genre,
                                 depositor_id: collection_users.sample&.id,
                                 collections: [collection].compact,
                                 is_public: [visibility, !visibility].sample,
                                 tei_authors: Faker::Creature.name
        )

        if core_file.save
          puts "Core file #{core_file.id} created within Collection #{collection.id}"

          record_image(core_file)
        else
          puts "Create Core Files task failed: #{core_file.errors.full_messages.join(', ')}"
        end
      end

      # Create 3 ography support files (don't need TEI)
      record_count_range.to_a.sample.times do
        core_file = CoreFile.create(title: Faker::Book.title,
                        description: Faker::Book.genre,
                        depositor_id: collection_users.sample&.id,
                        collections: [collection].compact,
                        is_public: visibility,
                        ography_type: ography_types.sample,
                        tei_authors: Faker::Artist.name
        )

        if core_file.persisted?
          puts "Ography file #{core_file.id} (#{core_file.ography_type}) created within Collection #{collection.id}"
          sleep 0.3  # Longer delay
        else
          puts "Create Ography Files task failed: #{core_file.errors.full_messages.join(', ')}"
        end
      end

      # Clear connection pool after each collection
      ActiveRecord::Base.connection_pool.release_connection
      puts "-> Completed collection #{collection.id}"
    end

    puts "Core file creation complete!"
  end

  def attach_tei_file(core_file)
    # Create a minimal valid TEI XML document
    tei_content = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <teiHeader>
          <fileDesc>
            <titleStmt>
              <title>#{core_file.title}</title>
            </titleStmt>
            <publicationStmt>
              <p>Sample TEI document for #{core_file.title}</p>
            </publicationStmt>
            <sourceDesc>
              <p>Generated dummy data</p>
            </sourceDesc>
          </fileDesc>
        </teiHeader>
        <text>
          <body>
            <p>This is a sample TEI document.</p>
          </body>
        </text>
      </TEI>
    XML

    # If RAW_TEI_URL is provided, try to fetch real TEI content
    if RAW_TEI_URL.present?
      begin
        tei_data = URI.open(RAW_TEI_URL)
        core_file.tei_file.attach(io: tei_data, filename: "#{core_file.title.parameterize}.xml", content_type: 'application/xml')
        return
      rescue => e
        puts "Failed to fetch TEI from URL, using generated content: #{e.message}"
      end
    end

    # Use generated TEI content as fallback
    core_file.tei_file.attach(
      io: StringIO.new(tei_content),
      filename: "#{core_file.title.parameterize}.xml",
      content_type: 'application/xml'
    )
  end

  desc 'generate all dummy data'
  task :run_all => :environment do
    # Check for Resque workers before proceeding
    check_resque_workers
    # Start or restart Solr service for connection to instance
    system('solr restart')

    Rake::Task['dummy_data_generator:user_records'].invoke
    Rake::Task['dummy_data_generator:non_user_records'].invoke
  end

  desc 'create user table records'
  task :user_records => :environment do
    puts 'Creating admin user...'
    Rake::Task['dummy_data_generator:admin_user'].invoke

    puts 'Creating debug user...'
    Rake::Task['dummy_data_generator:debug_non_admin_user'].invoke

    puts 'Creating non-admin users...'
    Rake::Task['dummy_data_generator:non_admin_users'].invoke
  end

  desc 'create non-user table records'
  task :non_user_records => :environment do
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

  desc "creates projects"
  task :projects => :environment do
    22.times do
      Project.create(title: Faker::Company.bs,
                     description: Faker::Lorem.paragraph,
                     depositor_id: User.all.sample.id,
                     institution: Faker::University.name
      )
    end

    3.times do
      Project.create(title: Faker::Company.bs,
                     description: Faker::Lorem.paragraph,
                     depositor_id: User.all.where(admin_at: nil).sample.id,
                     is_public: false,
                     institution: Faker::University.name
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

  desc 'creates core files'
  task :core_files => :environment do
    # Check for Resque workers before attaching files
    check_resque_workers

    if Collection.any?
      create_core_files
    else
      puts '"Create Collections" task failed. Cannot create core files.'
    end
  end

  desc "creates admin user"
  task :admin_user => :environment do
    email = ENV.fetch('DUMMY_ADMIN_EMAIL')
    password = ENV.fetch('DUMMY_ADMIN_PASSWORD')

    user = User.create(name: 'Admin',
                email: email,
                bio: Faker::Lorem.paragraph,
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
                bio: Faker::Lorem.paragraph,
                password: password
    )

    puts "Debug non-admin user #{user.id} has been created." unless user.nil?
  end

  desc "creates non-admin users"
  task :non_admin_users => :environment do
    50.times do
      user = User.create(name: Faker::Name.unique.name,
                  email: Faker::Internet.email,
                  bio: Faker::Lorem.paragraph,
                  password: Faker::Internet.password
      )

      puts "Non-admin user #{user.id} has been created." unless user.nil?
    end
  end

  desc 'deletes records from solr index'
  task :delete_indexed => :environment do
    SolrHelpers.delete_all_indexed_records
  end
end
