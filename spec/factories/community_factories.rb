FactoryGirl.define do 
  factory :community do 
    depositor "test_user" 
    sequence(:did) { |did| "#{did}" }
  end
end
