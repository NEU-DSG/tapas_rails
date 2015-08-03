FactoryGirl.define do 

  factory :collection do 
    depositor "test_user" 
    did { unique_did }
  end
end
