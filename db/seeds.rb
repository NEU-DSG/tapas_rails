# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'net/http'
require 'open-uri'
require 'dummy_data'
require 'pry'

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
  attach_tei(assoc_tei)
end

# this should occur when a core file is created and saved with a tei file
def attach_tei(tei_file)
  binding.pry
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

def project_member_ids(project)
  project.members.values.any? ? project.members.values.map(&:user_id) : []
end

def create_project_members
  puts 'Creating project members...'
  non_admin_ids = User.all.select { |u| u.admin_at.nil? }.map(&:id)
  Project.all.each do |project|
    # project owners
    # has created the project in question and has responsibility for it
    1.times do
      user_id = (non_admin_ids - project_member_ids(project)).sample

      ProjectMember.create(project_id: project.id,
                           user_id: user_id,
                           role: 'owner',
                           depositor?: true
      )
    end

    # contributors
    # has a TAPAS account and either creates or contributes to a TAPAS project
    4.times do
      user_id = (non_admin_ids - project_member_ids(project)).sample

      ProjectMember.create(project_id: project.id,
                           user_id: user_id,
                           role: 'contributor',
                           depositor?: project.depositor_id == user_id
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

def data_generated?
  [User, Project, ProjectMember, Collection].map(&:count).reduce(&:+) > 405
end

# users
admin_email = JSON.parse(ENV['APP_ADMINS'])[0]
admin_password = ENV.fetch('DUMMY_ADMIN_PASSWORD')
User.create(name: 'Admin',
            email: admin_email,
            bio: fake[:bio],
            password: admin_password,
            admin_at: DateTime.now
)
debug_email = ENV.fetch('DUMMY_DEBUG_EMAIL')
debug_password = ENV.fetch('DUMMY_DEBUG_PASSWORD')
User.create(name: 'Debug',
            email: debug_email,
            bio: fake[:bio],
            password: debug_password
)
248.times do
  User.create(name: fake[:person_name],
              email: fake[:email],
              bio: fake[:bio],
              password: fake[:password]
  )
end
puts "#{User.count} users created." if User.count == 250

# projects
22.times do
  Project.create(title: fake[:jargon],
                 description: fake[:bio],
                 depositor_id: User.where(admin_at: nil).sample.id,
                 institution: fake[:uni]
  )
end
3.times do
  Project.create(title: fake[:jargon],
                 description: fake[:bio],
                 depositor_id: User.where(admin_at: nil).sample.id,
                 is_public: false,
                 institution: fake[:uni]
  )
end
puts Project.count == 25 ? '25 Projects created.' : '"Create Projects" task failed.'

# project members, collections
if Project.any?
  create_project_members
  create_collections
else
  puts 'Create projects task failed.'
end

# core files
if data_generated?
  puts 'Creating core file ography types...'
  OgraphyType::DEFINITIONS.map { |k, v| OgraphyType.create(name: k, description: v) }
  puts 'Creating core files'
  create_core_files
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
