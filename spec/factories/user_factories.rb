FactoryBot.define do
  factory :user do
    sequence(:id) { |n| n }
    sequence(:email) { |n| "person_#{n}@example.com" }
    password { "password1" }
    api_key  { "test_api_key" }
    institution
  end
end
