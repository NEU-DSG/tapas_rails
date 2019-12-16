FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "person_#{n}@example.com" }
    password "password1"
    api_key  "test_api_key"
    sequence(:id) {|n| n }
  end
end
