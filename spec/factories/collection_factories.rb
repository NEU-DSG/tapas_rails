FactoryGirl.define do 

  factory :collection do 
    depositor "test_user" 
    sequence(:did) { |did| "#{did}" }
  end
end
