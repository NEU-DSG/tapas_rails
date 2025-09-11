namespace :dummy_data_generator do
  require 'faker'
  require 'net/http'
  require 'open-uri'

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

    record_assoc_image_file.save

    record.image_file.attach(io: image_data, filename: record_assoc_image_file.title, content_type: record_assoc_image_file.file_format)

    puts "Image file attached for #{record.class} #{record.id}"
  end

  def create_project_members
    # NOTE: Getting projects with no members will be much easier to do in Rails 6.1+, 
    # e.g. `Project.where.missing(:project_members)`
    Project.all.each do |project|
      non_admin_ids = User.all.select { |u| u.admin_at.nil? }.map(&:id)
      # 2025: Commented out "contributors" because a project should only have "administrators" and "collaborators"
      #num_contributors = Random.rand(5)   # 0 to 4
      num_collaborators = Random.rand(6)  # 0 to 5
      num_owners = 1 + Random.rand(4)     # 1 to 4

      # contributors
      # has a TAPAS account and either creates or contributes to a TAPAS project
      #num_contributors.times do
      #  user_id = (non_admin_ids - ProjectMember.all.map(&:user_id)).sample

      #  ProjectMember.create(project_id: project.id,
      #                       user_id: user_id,
      #                       role: 'contributor'
      #  )
      #end

      # collaborator
      # has editorial access to a TAPAS project but is not the owner
      num_collaborators.times do
        user_id = (non_admin_ids - ProjectMember.all.map(&:user_id)).sample

        ProjectMember.create(project_id: project.id,
                             user_id: user_id,
                             role: 'collaborator'
        )
      end

      # project owners
      # has created the project in question and has responsibility for it
      num_owners.times do
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

      3.times do
        public = Collection.create(title: Faker::Food.dish,
                                   description: Faker::GreekPhilosophers.quote,
                                   depositor_id: project_users.sample&.id,
                                   project_id: project.id,
                                   is_public: true
        )

        puts "Public collection #{public.id}: #{public.title} created for Project #{project.id}."
      end

      2.times do
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

      47.times do
        core_file = CoreFile.create(title: Faker::Book.title,
                        description: Faker::Book.genre,
                        depositor_id: collection_users.sample&.id,
                        collections: [collection].compact,
                        is_public: [visibility, !visibility].sample,
                        tei_authors: Faker::Creature.name
        )

        if core_file.id.nil? || !core_file.valid?
          puts 'Create Core Files task failed.'
        else
          puts "Core file #{core_file.id} created within Collection #{collection.id}"
          # TODO: revisit this for TEI files
          # record_image(core_file)
        end
      end

      3.times do
        CoreFile.create(title: Faker::Book.title,
                        description: Faker::Book.genre,
                        depositor_id: collection_users.sample&.id,
                        collections: [collection].compact,
                        is_public: visibility,
                        ography_type: ography_types.sample,
                        tei_authors: Faker::Artist.name
        )
      end
    end
  end

  desc 'generate all dummy data'
  task :run_all => :environment do
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

  # # split this out into separate tasks or methods for attaching image files to users, projects, and core files
  # desc 'attach image files'
  # task :image_files => :environment do
  #   if IMAGE_BASE_URL == nil
  #     puts "IMAGE_BASE_URL not set — skipping image attachment"
  #   else
  #     [
  #       # CoreFile,
  #       User,
  #       Collection,
  #       Project
  #     ].map(&:all).flatten.each do |o|
  #       image_file_name = "#{o.class}_#{o.id}"
  #
  #       record_image(o, image_file_name) unless o.image_file.attached?
  #     end
  #   end
  # end
end
