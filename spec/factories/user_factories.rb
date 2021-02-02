FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "person_#{n}@example.com" }
    password { 'password1' }
    api_key  { 'test_api_key' }
    institution
    admin_at { nil }
    username { |n| "user#{n}" }
    name { |n| "My Name #{n}"}
  end
end
