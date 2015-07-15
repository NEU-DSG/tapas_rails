FactoryGirl.define do 
  factory :core_file do 
    depositor "test_user" 
    did { unique_did }
  end
end
