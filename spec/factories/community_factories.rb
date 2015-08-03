FactoryGirl.define do 
  factory :community do 
    depositor "test_user" 
    did { unique_did }
  end
end
