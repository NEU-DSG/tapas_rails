FactoryBot.define do
  factory :community do
    sequence(:id) { |n| n }
    sequence(:title) { |n| "Community #{n}" }
    depositor factory: :user
  end
end
