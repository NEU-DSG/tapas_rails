FactoryBot.define do
  factory :project do
    sequence(:id) { |n| n }
    sequence(:title) { |n| "Community #{n}" }
    depositor factory: :user
  end
end
