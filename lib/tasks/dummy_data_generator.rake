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

  IMAGE_BASE_URL = 'https://raw.githubusercontent.com/NEU-DSG/tapas-view-packages/develop/teibp/images/tv_new_yo_gabba_gabba.jpg'
  RAW_TEI_URL = 'https://raw.githubusercontent.com/NEU-DSG/tapas-TEI-files/main/sample_files/letter.xml'

  def record_image(record, image_name=nil)
    url = "#{IMAGE_BASE_URL}"
    image_data = URI.open(url)
    image_name ||= "#{record.class}_#{record.__id__}"
    depositor_id = record.is_a?(User) ? record.id : record.depositor_id

    record.image_file.file.attach(io: image_data, filename: image_name, content_type: image_data.content_type)

    record_image = ImageFile.create(title: image_name, depositor_id: depositor_id, imageable_type: record.class.name, imageable_id: record.id, file_format: image_data.content_type)

    record_image.save

    puts "Image file attached for #{record.class} #{record.id}" if record_image.file.attached?

    # process image file metadata
    # if record_image.file.attached?
    #   record_image.file.analyze
    # end
  end

  desc "create admin user"
  task :generate_admin_user => :environment do
    email = ENV.fetch('DUMMY_ADMIN_EMAIL')
    password = ENV.fetch('DUMMY_ADMIN_PASSWORD')

    u = User.create(name: 'Admin',
                email: email,
                bio: Faker::Lorem.paragraph,
                password: password,
                admin_at: Time.now
    )

    user_avatar_name = "#{u.class}_#{u.id}"

    record_image(u, user_avatar_name)
  end

  desc "create debug non-admin user"
  task :generate_debug_non_admin_user => :environment do
    email = ENV.fetch('DUMMY_DEBUG_EMAIL')
    password = ENV.fetch('DUMMY_DEBUG_PASSWORD')

    User.create(name: 'Debug',
                email: email,
                bio: Faker::Lorem.paragraph,
                password: password
    )
  end

  desc "create non-admin users"
  task :generate_non_admin_users => :environment do
    50.times do
      user = User.create(name: Faker::Name.unique.name,
                  email: Faker::Internet.email,
                  bio: Faker::Lorem.paragraph,
                  password: Faker::Internet.password
      )

      puts "Non-admin user #{user.id} has been created." unless user.nil?
    end
  end

  desc 'attach user avatars'
  task :attach_user_avatars => :environment do
    User.all.each do |u|
      user_avatar_name = "#{u.class}_#{u.id}"

      record_image(u, user_avatar_name)
    end
  end

  desc "create public projects"
  task :generate_public_projects => :environment do
    25.times do
      project = Project.create(title: Faker::Company.bs,
                     description: Faker::Lorem.paragraph,
                     depositor_id: User.all.sample.id
      )

      puts "Public project #{project.id} has been created." unless project.nil?
    end
  end

  desc "create private projects"
  task :generate_private_projects => :environment do
    10.times do
      project = Project.create(title: Faker::Company.bs,
                     description: Faker::Lorem.paragraph,
                     depositor_id: User.all.sample.id,
                     is_public: 'false'
      )
      puts "Private project #{project.id} has been created." unless project.nil?
    end

    Project.each do |p|
      project_thumbnail_name = "#{p.class}_#{p.id}"

      record_image(p, project_thumbnail_name)
    end
  end

  desc 'create project members'
  task :generate_project_members => :environment do
    Project.all.each do |project|
      5.times do
        ProjectMember.create(project_id: project.id,
                             user_id: User.all.where(admin_at: nil).sample.id,
                             role: 'contributor'
      )
      end
      2.times do
        ProjectMember.create(project_id: project.id,
                             user_id: User.all.where(admin_at: nil).sample.id,
                             role: 'editor'
        )
      end
      1.times do
        ProjectMember.create(project_id: project.id,
                             user_id: User.all.where(admin_at: nil).sample.id,
                             role: 'owner'
        )
      end
    end
  end

  desc 'create public collections'
  task :generate_public_collections => :environment do
    75.times do
      Collection.create(title: Faker::Food.dish,
                        description: Faker::GreekPhilosophers.quote,
                        depositor_id: User.all.sample.id,
                        project_id: Project.all.sample.id
      )
    end
  end

  desc 'create private collections'
  task :generate_private_collections => :environment do
    25.times do
      Collection.create(title: Faker::Food.dish,
                        description: Faker::GreekPhilosophers.quote,
                        depositor_id: User.all.sample.id,
                        project_id: Project.all.sample.id,
                        is_public: 'false'
      )
    end
  end

  desc 'create public core files'
  task :generate_public_core_files => :environment do
    200.times do
      CoreFile.create(title: Faker::Book.title,
                      description: Faker::Book.genre,
                      depositor_id: User.all.sample.id,
                      collection_ids: Collection.all.sample.id
      )
    end
  end

  desc 'create private core files'
  task :generate_private_core_files => :environment do
    50.times do
      CoreFile.create(title: Faker::Book.title,
                      description: Faker::Book.genre,
                      depositor_id: User.all.sample.id,
                      collection_ids: Collection.all.sample.id,
                      is_public: 'false'
      )
    end
  end

  desc 'create core files as ographies'
  task :generate_core_files_as_ographies => :environment do
    ography_types = CoreFile.all_ography_types

    50.times do
      CoreFile.create(title: Faker::Book.title,
                      description: Faker::Book.genre,
                      depositor_id: User.all.sample.id,
                      collection_ids: Collection.all.sample.id,
                      is_public: 'true',
                      ography_type: ography_types.sample
      )
    end

    25.times do
      CoreFile.create(title: Faker::Book.title,
                      description: Faker::Book.genre,
                      depositor_id: User.all.sample.id,
                      collection_ids: Collection.all.sample.id,
                      is_public: 'false',
                      ography_type: ography_types.sample
      )
    end
  end

  desc 'generate all dummy data'
  task :run_all_generate_tasks => :environment do
    puts 'Creating admin user...'
    Rake::Task['dummy_data_generator:generate_admin_user'].invoke

    Rake::Task['dummy_data_generator:generate_debug_non_admin_user'].invoke

    puts 'Creating non-admin users...'
    Rake::Task['dummy_data_generator:generate_non_admin_users'].invoke

    puts 'Adding user avatar image files...'
    Rake::Task['dummy_data_generator:attach_user_avatars'].invoke

    puts 'Creating public projects...'
    Rake::Task['dummy_data_generator:generate_public_projects'].invoke

    puts 'Creating private projects...'
    Rake::Task['dummy_data_generator:generate_private_projects'].invoke

    puts 'Creating project members...'
    Rake::Task['dummy_data_generator:generate_project_members'].invoke

    puts 'Creating private collections...'
    Rake::Task['dummy_data_generator:generate_private_collections'].invoke

    puts 'Creating project_collection join table records'
    Rake::Task['dummy_data_generator:generate_project_collections'].invoke

    puts 'Creating public core files...'
    Rake::Task['dummy_data_generator:generate_public_core_files'].invoke

    puts 'Creating private core files...'
    Rake::Task['dummy_data_generator:generate_private_core_files'].invoke

    puts 'Creating ography core files...'
    Rake::Task['dummy_data_generator:generate_core_files_as_ographies'].invoke
  end
end
