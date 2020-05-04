FactoryBot.define do

  factory :collection do
    depositor { "test_user" }
    title { "Collection" }
    did { unique_did }
  end
end
