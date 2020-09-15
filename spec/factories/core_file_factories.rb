FactoryBot.define do
  factory :core_file do
    association :depositor, factory: :user
    title { "title" }
  end
end
