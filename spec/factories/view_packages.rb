# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :view_package do

    factory :tapas_generic do
      machine_name "tapas_generic"
    end

    factory :teibp do
      machine_name "teibp"
    end
  end
end
