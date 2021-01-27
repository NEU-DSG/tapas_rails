FactoryBot.define do
  factory :institution do
    sequence(:name) { |n| "Institution #{n}" }

    url { "https://tapasrails.com/institution" }
  end
end
