FactoryGirl.define do 
  factory :core_file do 
    depositor "test_user" 
    sequence(:nid) { |nid| "#{nid}" }
  end
end
