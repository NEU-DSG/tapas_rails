FactoryBot.define do
  factory :institution do
    sequence(:id) { |n| n }
    sequence(:name) { |n| "Institution ${n}" }

    url { "https://tapasrails.com/institution" }
  end
end
