namespace :dummy_data_generator do
  require 'faker'

  desc "create institutions"
  task :generate_institutions => :environment do
    50.times do
      Institution.create(name: Faker::Educator.university,
                         description: Faker::Lorem.paragraph,
                         address: Faker::Address.full_address,
                         url: Faker::Internet.url
      )
    end
  end

  desc "create admin user"
  task :generate_admin_user => :environment do
    User.create(name: 'Admin',
                email: 'admin@email.com',
                bio: Faker::Lorem.paragraph,
                password: 'Admin-pdub!',
                institution_id: Institution.all.sample.id,
                admin_at: Time.now
    )
  end

  desc "create non-admin user"
  task :generate_non_admin_users => :environment do
    100.times do
      User.create(name: Faker::Name.unique.name,
                  email: Faker::Internet.email,
                  bio: Faker::Lorem.paragraph,
                  password: Faker::Internet.password,
                  institution_id: Institution.all.sample.id
      )
    end
  end

  desc "create public communities"
  task :generate_public_communities => :environment do
    75.times do
      Community.create(title: Faker::Company.bs,
                       description: Faker::Lorem.paragraph,
                       depositor_id: User.all.sample.id
      )
    end
  end

  desc "create private communities"
  task :generate_private_communities => :environment do
    25.times do
      Community.create(title: Faker::Company.bs,
                       description: Faker::Lorem.paragraph,
                       depositor_id: User.all.sample.id,
                       is_public: 'false'
      )
    end
  end

  desc 'create community members'
  task :generate_community_members => :environment do
    Community.all.each do |community|
      10.times do
        CommunityMember.create(community_id: community.id,
                              user_id: User.all.sample.id
      )
      end

      3.times do
        CommunityMember.create(community_id: community.id,
                               user_id: User.all.sample.id,
                               member_type: 'editor'
        )
      end

      2.times do
        CommunityMember.create(community_id: community.id,
                               user_id: User.all.sample.id,
                               member_type: 'admin'
        )
      end
    end
  end

  desc 'create public collections'
  task :generate_public_collections => :environment do
    125.times do
      Collection.create(title: Faker::Food.dish,
                        description: Faker::GreekPhilosophers.quote,
                        depositor_id: User.all.sample.id,
                        community_id: Community.all.sample.id
      )
    end
  end

  desc 'create private collections'
  task :generate_private_collections => :environment do
    50.times do
      Collection.create(title: Faker::Food.dish,
                        description: Faker::GreekPhilosophers.quote,
                        depositor_id: User.all.sample.id,
                        community_id: Community.all.sample.id,
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
    puts 'Creating institutions...'
    Rake::Task['dummy_data_generator:generate_institutions'].invoke

    puts 'Creating admin user...'
    Rake::Task['dummy_data_generator:generate_admin_user'].invoke

    puts 'Creating non-admin users...'
    Rake::Task['dummy_data_generator:generate_non_admin_users'].invoke

    puts 'Creating public communities...'
    Rake::Task['dummy_data_generator:generate_public_communities'].invoke

    puts 'Creating private communities...'
    Rake::Task['dummy_data_generator:generate_private_communities'].invoke

    puts 'Creating community members...'
    Rake::Task['dummy_data_generator:generate_community_members'].invoke

    puts 'Creating public collections...'
    Rake::Task['dummy_data_generator:generate_public_collections'].invoke

    puts 'Creating private collections...'
    Rake::Task['dummy_data_generator:generate_private_collections'].invoke

    puts 'Creating public core files...'
    Rake::Task['dummy_data_generator:generate_public_core_files'].invoke

    puts 'Creating private core files...'
    Rake::Task['dummy_data_generator:generate_private_core_files'].invoke

    puts 'Creating ography core files...'
    Rake::Task['dummy_data_generator:generate_core_files_as_ographies'].invoke
  end
end
