FactoryBot.define do
  factory :html_file, :class => HTMLFile do
    depositor { 'test_user' }
  end
end
