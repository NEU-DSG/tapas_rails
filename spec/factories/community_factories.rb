FactoryBot.define do
  factory :community do
    depositor "test_user"
    title "Root Community"
    did { unique_did }
  end
end
