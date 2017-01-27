# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :view_package do
    human_name "MyString"
    machine_name "MyString"
    description "MyText"
    file_type "MyText"
    css_dir "MyString"
    js_dir "MyString"
    parameters "MyText"
    run_process "MyText"
  end
end
