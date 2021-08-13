# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :view_package do

    factory :tapas_generic do
      machine_name { "tapas_generic" }
      dir_name { "tapas-generic" }
    end

    factory :teibp do
      machine_name { "teibp" }
      dir_name { "teibp" }
    end
  end
end
