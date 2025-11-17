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
    # NOTE: Getting projects with no members will be much easier to do in Rails 6.1+, 
    # e.g. `Project.where.missing(:project_members)`
    Project.all.each do |project|
      non_admin_ids = User.all.select { |u| u.admin_at.nil? }.map(&:id)
      available_users = non_admin_ids #- ProjectMember.all.map(&:user_id)
      num_contributors = Random.rand(13)   # 0 to 12
      num_owners = Random.rand(6)   # 0 to 5, plus the depositor

      # project owners
      # has full edit access for the project
      # can create collections and core files
      # Start with the project depositor.
      ProjectMember.create(project_id: project.id,
                            user_id: project.depositor_id,
                            role: 'owner'
      )
      # Remove the depositor from the array of available users.
      available_users.delete(project.depositor_id)
      # Create any additional owners.
      num_owners.times do
        user_id = available_users.sample
        available_users.delete(user_id)

        ProjectMember.create(project_id: project.id,
                             user_id: user_id,
                             role: 'owner'
        )
      end

      # contributor
      # has access to a TAPAS project but is not the owner
      # can create core files but not collections
      num_contributors.times do
        user_id = available_users.sample

        ProjectMember.create(project_id: project.id,
                             user_id: user_id,
                             role: 'contributor'
        )
      end

      puts "#{project.owner.flatten.length} project owners created for #{project.__id__}"
      if project.contributors
        puts "#{project.contributors.flatten.length} project contributors created for #{project.__id__}"
      end
    end
  end

  def create_collections
    Project.all.each do |project|
      project_owners = project.owner.flatten.shuffle
      older_collections = project.collections.length
      is_empty = Random.rand(101) >= 95  # Very low chance for a project to have 0 collections
      num_collections = is_empty ? 0 : 1 + Random.rand(5) # 0 to 5

      num_collections.times do
        # If the project is public, the collection can be public or private.
        # If the project is private, the new collection must be too.
        visibility = project.is_public ? [true, false].sample : false
        collection = Collection.create(title: Faker::Food.dish,
                                   description: Faker::GreekPhilosophers.quote,
                                   depositor_id: project_owners.sample&.id,
                                   project_id: project.id,
                                   is_public: visibility
        )

        puts (visibility ? "Public" : "Private") + 
          " collection #{collection.id}: #{collection.title} created for Project #{project.id}."
      end
    end
  end
  
  def create_new_core_file(collection, users, ography_type = nil)
    project = collection.project
    visibility = collection.is_public
    core_file = CoreFile.create(title: Faker::Book.title,
                    description: Faker::Book.genre,
                    depositor_id: users.sample&.id,
                    collections: [collection].compact,
                    is_public: visibility ? [visibility, !visibility].sample : visibility,
                    tei_authors: Faker::Creature.name,
                    ography_type: ography_type
    )

    # Attach TEI file (required for non-ography files)
    attach_tei_file(core_file)

    if core_file.save
      #puts "Core file #{core_file.id} created within Collection #{collection.id}"
      # record_image(core_file)
    else
      puts "Create Core Files task failed: #{core_file.errors.full_messages.join(', ')}"
    end
  end

  def create_core_files
    Collection.all.each do |collection|
      collection_users = collection.project.members.values.flatten.shuffle
      ography_types = CoreFile.all_ography_types
      older_core_files = collection.core_files.length
      num_core_files = Random.rand(51) # 0 to 50
      num_ography_files = Random.rand(3) # 0 to 2

      num_core_files.times do
        create_new_core_file(collection, collection_users)
      end

      # Create 0 to 2 ography support files
      num_ography_files.times do
        create_new_core_file(collection, collection_users, ography_types.sample)
      end
      
      puts "Created "+ (collection.core_files.reload.size - older_core_files).to_s + " core files within Collection #{collection.id}"

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
    # Check the number of Projects we had before creating new ones
    older_projects = Project.count
    num_projects = 45
    
    num_projects.times do
      # Pick a number between 0 and 2. If the number is 2, the project is private.
      is_private = Random.rand(3) == 2
      # Pick a number between 0 and 3. If the number is 3, generate an institution string.
      include_institution = Random.rand(4) == 3
      
      Project.create(title: Faker::Company.bs,
                     description: Faker::Lorem.paragraph,
                     depositor_id: User.all.where(admin_at: nil).sample.id,
                     is_public: !is_private,
                     institution: include_institution ? Faker::University.name : nil
      )
    end

    puts Project.count == num_projects + older_projects ? num_projects.to_s + ' Projects created.' 
          : '"Create Projects" task failed.'
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
    275.times do
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
