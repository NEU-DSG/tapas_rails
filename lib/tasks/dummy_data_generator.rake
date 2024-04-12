namespace :dummy_data_generator do
  desc "create dummy data for db development"
  task :generate_institutions do
    require './app/models/institution.rb'
    require 'faker'

    50.times do
      Institution.create(name: Faker::University.name, description: Faker::Lorem.paragraph, address: Faker::Address.full_address, url: Faker::Internet.url)
    end
  end
end
