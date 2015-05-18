FactoryGirl.define do 
  factory :core_file do 
    depositor "test_user" 
    sequence(:did) { |did| "#{did}" }
  end
end
