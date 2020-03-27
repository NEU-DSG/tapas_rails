class TestPropertiesDatastream < CerberusCore::Datastreams::PropertiesDatastream 
  use_terminology CerberusCore::Datastreams::PropertiesDatastream 

  extend_terminology do |t| 
    t.test_attribute(path: 'testAttribute', namespace: 'dc')
  end

  def get_depositor 
    self.depositor.first
  end
end