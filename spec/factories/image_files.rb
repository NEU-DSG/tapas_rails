FactoryBot.define do
  factory :image_file do
    title { "Test Image" }
    association :depositor, factory: :user
    description { "A test image file" }
    file_format { "image/png" }

    # Polymorphic association - can be used with different imageables
    trait :for_core_file do
      association :imageable, factory: :core_file
    end

    trait :for_collection do
      association :imageable, factory: :collection
    end

    trait :for_project do
      association :imageable, factory: :project
    end

    trait :for_user do
      association :imageable, factory: :user
    end

    # Optionally attach a file after creation
    after(:build) do |image_file|
      # image_file.file.attach(
      #   io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png')),
      #   filename: 'test_image.png',
      #   content_type: 'image/png'
      # )
    end
  end
end
