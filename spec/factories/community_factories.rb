FactoryBot.define do
  factory :community do
    sequence(:title) { |n| "Community #{n}" }
    depositor factory: :user
  end
end
