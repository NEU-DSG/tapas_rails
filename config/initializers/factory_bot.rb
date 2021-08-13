if defined? FactoryBot
  require "#{Rails.root}/spec/support/factory_helpers"
  FactoryBot::SyntaxRunner.send(:include, FactoryHelpers)
end
