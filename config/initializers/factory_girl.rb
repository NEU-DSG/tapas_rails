if defined? FactoryGirl
  require "#{Rails.root}/spec/support/factory_helpers"
  FactoryGirl::SyntaxRunner.send(:include, FactoryHelpers)
end
