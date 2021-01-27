FactoryBot.define do

  factory :collection do
    depositor factory: :user
    community
    is_public { false }
    sequence(:title) { |n| "Collection #{n}" }
    sequence(:description) { |n| "Description #{n}" }
  end
end
